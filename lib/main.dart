import 'package:ecom/features/presentation/providers/product_provider.dart';
import 'package:ecom/features/presentation/providers/category_provider.dart';
import 'package:ecom/features/presentation/providers/order_provider.dart';
import 'package:ecom/core/providers/navigation_provider.dart';
import 'package:ecom/core/providers/locale_provider.dart';
import 'package:ecom/core/services/notification_service.dart';
import 'package:ecom/features/presentation/providers/settings_provider.dart';
import 'package:ecom/features/presentation/providers/notification_provider.dart';
import 'package:ecom/firebase_options.dart';
import 'package:ecom/features/presentation/providers/cart_provider.dart';
import 'package:ecom/features/presentation/providers/wishlist_provider.dart';
import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/features/presentation/providers/payment_provider.dart';
import 'package:ecom/features/presentation/providers/address_provider.dart';
import 'package:ecom/features/presentation/providers/review_provider.dart';
import 'package:ecom/core/theme/theme_provider.dart';
import 'package:ecom/features/domain/models/product_model.dart';
import 'package:ecom/features/domain/models/cart_item_model.dart';
import 'package:ecom/features/domain/models/user_model.dart';
import 'package:ecom/features/domain/models/notification_model.dart';
import 'package:ecom/features/domain/models/address_model.dart';
import 'package:ecom/core/services/encryption_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/presentation/screens/splash/splash_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Initialize Notifications
  NotificationService().initialize();

  // Initialize Hive
  await Hive.initFlutter();
  
  // Get Encryption Key
  final encryptionKey = await EncryptionService.getEncryptionKey();
  
  // Register Hive Adapters
  Hive.registerAdapter(ProductModelAdapter()); // 0
  Hive.registerAdapter(CartItemModelAdapter()); // 1
  Hive.registerAdapter(UserModelAdapter()); // 2
  Hive.registerAdapter(NotificationModelAdapter()); // 3
  Hive.registerAdapter(NotificationTypeAdapter()); // 4
  // TypeId 5 is reserved/skipped to avoid legacy conflicts
  Hive.registerAdapter(AddressModelAdapter()); // 6
  
  // Open Boxes
  await Hive.openBox<CartItemModel>('cart_box');
  await Hive.openBox<ProductModel>('wishlist_box');
  await Hive.openBox<UserModel>('user_box', encryptionCipher: HiveAesCipher(encryptionKey));
  await Hive.openBox<NotificationModel>('notifications_box');
  await Hive.openBox<AddressModel>('addresses_box', encryptionCipher: HiveAesCipher(encryptionKey));
  await Hive.openBox('settings_box');
  
  // Load the saved preferences before the app starts
  final bool isDarkMode = await ThemeProvider.getThemePreference();
  final String? languageCode = await LocaleProvider.getLocalePreference();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(initialIsDark: isDarkMode),
        ),
        ChangeNotifierProvider(
          create: (context) => LocaleProvider(initialLanguageCode: languageCode),
        ),
        ChangeNotifierProvider(
          create: (context) => NavigationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => WishlistProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PaymentProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AddressProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ReviewProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SettingsProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wonder Kids',
      theme: themeProvider.themeData,
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}
