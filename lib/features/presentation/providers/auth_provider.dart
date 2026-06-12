import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ecom/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecom/features/domain/models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Box<UserModel> _userBox = Hive.box<UserModel>('user_box');
  final Box _settingsBox = Hive.box('settings_box');

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  bool get isAuthenticated => _currentUser != null;

  StreamSubscription? _userDocSubscription;

  bool get hasSeenOnboarding =>
      _settingsBox.get('has_seen_onboarding', defaultValue: false);

  AuthProvider() {
    _loadUserFromHive();
    // Listen to Firebase Auth state changes
    _auth.userChanges().listen(_onAuthStateChanged);

    // FIX: Disable app verification (reCAPTCHA/App Attest) for iOS simulators.
    if (Platform.isIOS) {
      _auth.setSettings(appVerificationDisabledForTesting: true);
    }
  }

  @override
  void dispose() {
    _userDocSubscription?.cancel();
    super.dispose();
  }

  Future<void> setHasSeenOnboarding() async {
    await _settingsBox.put('has_seen_onboarding', true);
    notifyListeners();
  }

  void _loadUserFromHive() {
    if (_userBox.isNotEmpty) {
      _currentUser = _userBox.get('current_user');
      notifyListeners();
    }
  }

  // Robust listener with real-time sync for profile/admin changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _userDocSubscription?.cancel();

    if (firebaseUser == null) {
      debugPrint('Auth: User is null (signed out)');
      _currentUser = null;
      await _userBox.delete('current_user');
      _isInitialized = true;
      notifyListeners();
      return;
    }

    debugPrint('Auth: User detected: ${firebaseUser.uid}. Listening for updates...');
    
    // 1. Set up real-time listener for the user document
    _userDocSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          // Use UserModel.fromMap for consistency
          _currentUser = UserModel.fromMap(data).copyWith(
            uid: firebaseUser.uid,
            email: data['email'] ?? firebaseUser.email ?? '',
          );
        } else {
          // Fallback if data is null but snapshot exists
          _currentUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
            phoneNumber: firebaseUser.phoneNumber,
            isAdmin: false,
          );
        }
        
        await _userBox.put('current_user', _currentUser!);
        _isInitialized = true;
        notifyListeners();
      } else {
        // 2. Document doesn't exist yet (first time or social login)
        _createDefaultUserDoc(firebaseUser);
      }
    }, onError: (e) {
      debugPrint('Auth Doc Listener Error: $e');
      // Fallback to manual sync if listener fails (e.g. security rules)
      _manualSync(firebaseUser);
    });

    // 3. Background FCM Sync
    _updateFCMToken();
  }

  Future<void> _createDefaultUserDoc(User firebaseUser) async {
    try {
      debugPrint('Auth Sync: Creating default user document...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set({
        'uid': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'displayName': firebaseUser.displayName,
        'photoUrl': firebaseUser.photoURL,
        'phoneNumber': firebaseUser.phoneNumber,
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Auth Sync Creation Warning: $e');
    }
  }

  Future<void> _manualSync(User firebaseUser) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null) {
          _currentUser = UserModel.fromMap(data).copyWith(
            uid: firebaseUser.uid,
            email: data['email'] ?? firebaseUser.email ?? '',
          );
        } else {
          _currentUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
            phoneNumber: firebaseUser.phoneNumber,
            isAdmin: false,
          );
        }
        await _userBox.put('current_user', _currentUser!);
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Auth Manual Sync Warning: $e');
      // Final fallback to auth object only
      _currentUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        phoneNumber: firebaseUser.phoneNumber,
        isAdmin: false,
      );
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _updateFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken().timeout(
        const Duration(seconds: 5),
      );
      if (token != null) {
        await NotificationService()
            .saveTokenToFirestore(token)
            .timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      debugPrint('FCM Token skipped: $e');
    }
  }

  Future<void> testFirestoreConnection() async {
    try {
      debugPrint('Testing Firestore connection...');
      await FirebaseFirestore.instance
          .collection('health')
          .doc('check')
          .get()
          .timeout(const Duration(seconds: 5));
      debugPrint('Firestore connection OK');
    } catch (e) {
      debugPrint('Firestore connection test failed: $e');
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    debugPrint('SignUp: Starting process for $email');
    _isLoading = true;
    notifyListeners();

    UserCredential? credential;
    try {
      // 1. Create Auth User
      debugPrint('SignUp: Step 1 - Creating Auth user...');
      credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 40));

      debugPrint(
        'SignUp: Auth user created successfully: ${credential.user?.uid}',
      );

      // 2. Update Profile Display Name immediately on the Auth object
      if (credential.user != null) {
        debugPrint('SignUp: Step 2 - Updating display name to "$name"...');
        await credential.user!
            .updateDisplayName(name)
            .timeout(const Duration(seconds: 15))
            .catchError((e) {
          debugPrint('SignUp: Warning - Display name update failed: $e');
          return null;
        });

        // Also update Firestore doc directly to ensure it's not null in DB
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'displayName': name,
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 10));

        // We'll let _onAuthStateChanged handle the Firestore document creation
        // but we'll trigger a reload to make sure the display name is available for it
        await credential.user
            ?.reload()
            .timeout(const Duration(seconds: 10))
            .catchError((e) => null);
        debugPrint('SignUp: User reloaded after name update.');

        // 3. Force create Firestore document immediately to avoid race conditions
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'uid': credential.user!.uid,
          'email': email,
          'displayName': name,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 15));
      }

      // 4. Force sync provider state before returning
      if (credential.user != null) {
        await _onAuthStateChanged(credential.user);
      }

      debugPrint('SignUp: Registration process finished successfully.');
    } on FirebaseAuthException catch (e) {
      debugPrint('SignUp: Auth Error [${e.code}]: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('SignUp: Unexpected Error: $e');
      if (e is TimeoutException) {
        debugPrint(
          'SignUp: TIMEOUT - This may be due to Firestore not being enabled or network restrictions.',
        );
      }
      if (credential == null) rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    debugPrint('SignIn: Attempting login for $email');
    _isLoading = true;
    notifyListeners();
    try {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 30));
      debugPrint('SignIn: Success');

      // Force sync provider state before returning to avoid race conditions in UI
      if (_auth.currentUser != null) {
        await _onAuthStateChanged(_auth.currentUser);
      }

      if (rememberMe) {
        await _settingsBox.put('rememberED_email', email);
        await _settingsBox.put('remember_me', true);
      } else {
        await _settingsBox.delete('rememberED_email');
        await _settingsBox.put('remember_me', false);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('SignIn: Auth Error [${e.code}]: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('SignIn: Unexpected Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? get rememberedEmail => _settingsBox.get('rememberED_email');
  bool get isRememberMeChecked =>
      _settingsBox.get('remember_me', defaultValue: false);

  Future<void> signOut() async {
    await _auth.signOut();
    await _userBox.clear();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    try {
      // Check if user exists in Firestore first
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));

      if (query.docs.isEmpty) {
        throw 'No account found with this email address.';
      }

      await _auth
          .sendPasswordResetEmail(email: email)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    _isLoading = true;
    notifyListeners();
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String uid = user.uid;

        // 1. Delete Storage data (non-critical)
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_photos')
              .child('$uid.jpg');
          await storageRef.delete().timeout(const Duration(seconds: 5));
        } catch (e) {
          debugPrint('Storage delete skipped: $e');
        }

        // 2. Delete Firestore data
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .delete()
            .timeout(const Duration(seconds: 10));

        // 3. Delete Auth User
        await user.delete().timeout(const Duration(seconds: 10));

        await _userBox.clear();
        _currentUser = null;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Delete Account Error: ${e.code}');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    _isLoading = true;
    notifyListeners();
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user
              .updateDisplayName(displayName)
              .timeout(const Duration(seconds: 5));
        }
        if (photoUrl != null) {
          await user
              .updatePhotoURL(photoUrl)
              .timeout(const Duration(seconds: 5));
        }

        Map<String, dynamic> updates = {};
        if (displayName != null) updates['displayName'] = displayName;
        if (photoUrl != null) updates['photoUrl'] = photoUrl;
        if (updates.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update(updates)
              .timeout(const Duration(seconds: 10));
        }

        await user.reload().timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadProfilePhoto(Uint8List imageData) async {
    _isLoading = true;
    notifyListeners();
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}.jpg');

      // Use putData instead of putFile for better reliability on iOS
      await storageRef.putData(
        imageData,
        SettableMetadata(contentType: 'image/jpeg'),
      ).timeout(const Duration(minutes: 2));

      final downloadUrl = await storageRef.getDownloadURL();

      await updateProfile(photoUrl: downloadUrl);
    } catch (e) {
      debugPrint('Upload Photo Error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
