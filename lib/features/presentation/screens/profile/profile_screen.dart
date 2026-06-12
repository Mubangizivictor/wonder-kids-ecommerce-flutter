// ignore_for_file: unused_local_variable

import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/features/presentation/providers/settings_provider.dart';
import 'package:ecom/features/presentation/screens/auth/widgets/auth_guard.dart';
import 'package:ecom/features/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:ecom/core/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/profile_section.dart';
import '../profile_settings/profile_settings_screen.dart';
import 'personal_info/personal_info_screen.dart';
import 'payment_methods/payment_methods_screen.dart';
import 'shipping_addresses/shipping_addresses_screen.dart';
import 'notifications/notifications_screen.dart';
import 'help_center/help_center_screen.dart';
import 'privacy_policy/privacy_policy_screen.dart';
import '../order_history/order_history_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../auth/login_screen.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'widgets/logout_dialog.dart';

import 'widgets/language_selector_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isLoggedIn = authProvider.isAuthenticated;
    final bool isAdmin = authProvider.currentUser?.isAdmin ?? false;
    
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profile,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (isLoggedIn)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
                );
              },
              icon: const Icon(LucideIcons.settings),
            ),
        ],
      ),
      extendBodyBehindAppBar: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: FadeInAnimation(
          child: Column(
            children: [
            const ProfileHeader(),
            const SizedBox(height: 32),
            
            if (isLoggedIn) ...[
              if (isAdmin) ...[
                ProfileSection(
                  title: l10n.accountActions,
                  children: [
                    ProfileMenuItem(
                      icon: LucideIcons.layoutDashboard,
                      title: 'Admin Panel',
                      subtitle: 'Manage products, orders, and categories',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
              ProfileSection(
                title: l10n.myExperience,
                children: [
                  ProfileMenuItem(
                    icon: LucideIcons.shoppingBag,
                    title: l10n.orderHistory,
                    subtitle: l10n.orderHistorySubtitle,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: LucideIcons.heart,
                    title: l10n.myWishlist,
                    subtitle: l10n.myWishlistSubtitle,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WishlistScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: LucideIcons.creditCard,
                    title: l10n.paymentMethods,
                    subtitle: l10n.paymentMethodsSubtitle,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                      );
                    },
                  ),
                ],
              ),

              ProfileSection(
                title: l10n.accountSettings,
                children: [
                  ProfileMenuItem(
                    icon: LucideIcons.user,
                    title: l10n.personalInformation,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: LucideIcons.mapPin,
                    title: l10n.shippingAddresses,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ShippingAddressesScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: LucideIcons.bell,
                    title: l10n.notifications,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],

            ProfileSection(
              title: l10n.preferencesSupport,
              children: [
                ProfileMenuItem(
                  icon: LucideIcons.languages,
                  title: l10n.language,
                  subtitle: l10n.languageSubtitle,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LanguageSelectorDialog(),
                    );
                  },
                ),
                const Divider(height: 1),
                ProfileMenuItem(
                  icon: LucideIcons.helpCircle,
                  title: l10n.helpCenter,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ProfileMenuItem(
                  icon: LucideIcons.shieldCheck,
                  title: l10n.privacyPolicy,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),
            if (isLoggedIn)
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withAlpha(40)),
                ),
                child: ListTile(
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => const LogoutDialog(),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.logOut, size: 20, color: Colors.redAccent),
                  ),
                  title: Text(
                    l10n.logOut,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(LucideIcons.chevronRight, size: 18, color: Colors.redAccent),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(l10n.loginToYourAccount),
                ),
              ),
            const SizedBox(height: 40),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(128),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      )),
    );
  }
}
