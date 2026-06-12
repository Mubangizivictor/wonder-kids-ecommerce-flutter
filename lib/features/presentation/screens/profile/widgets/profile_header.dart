import 'dart:io';
import 'dart:typed_data';
import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final authProvider = context.read<AuthProvider>();
    final l10n = AppLocalizations.of(context)!;

    try {
      // Pick image from gallery
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        setState(() => _isUploading = true);
        
        // Read bytes immediately to avoid "Permission Denied" errors on iOS path access
        final Uint8List bytes = await image.readAsBytes();
        
        if (bytes.isEmpty) {
          throw Exception("Picked image is empty");
        }
        
        await authProvider.uploadProfilePhoto(bytes);
        
        if (mounted) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.photoUpdated),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Profile Photo Upload Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString().split(',').last}'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(milliseconds: 3000),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final user = authProvider.currentUser;
    final bool isLoggedIn = authProvider.isAuthenticated;

    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(80),
                    width: 1,
                  ),
                ),
                child: Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withAlpha(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _isUploading
                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                        : (isLoggedIn && user?.photoUrl != null)
                            ? Image.network(
                                user!.photoUrl!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(LucideIcons.user, size: 50, color: theme.colorScheme.primary),
                              )
                            : Icon(LucideIcons.user, size: 50, color: theme.colorScheme.primary),
                  ),
                ),
              ),
              if (isLoggedIn)
                PositionedDirectional(
                  bottom: 4,
                  end: 4,
                  child: GestureDetector(
                    onTap: _isUploading ? null : _pickAndUploadImage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isUploading ? Colors.grey : theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        _isUploading ? LucideIcons.loader2 : LucideIcons.camera,
                        size: 18,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isLoggedIn ? (user?.displayName ?? 'User') : l10n.welcomeGuest,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        if (isLoggedIn)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user?.email ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          )
        else
          Text(
            l10n.loginToManageOrders,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(120),
            ),
          ),
      ],
    );
  }
}
