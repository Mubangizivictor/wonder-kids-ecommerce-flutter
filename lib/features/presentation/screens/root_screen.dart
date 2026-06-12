// ignore_for_file: unused_field

import 'package:ecom/core/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/presentation/screens/auth/widgets/auth_guard.dart';
import 'package:ecom/features/presentation/screens/shop/shop_screen.dart';
import 'package:ecom/features/presentation/screens/wishlist/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecom/core/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'home/home_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ShopScreen(),
    const AuthGuard(child: WishlistScreen()),
    const AuthGuard(child: CartScreen()),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap(int index, NavigationProvider navigationProvider) {
    if (navigationProvider.currentIndex != index) {
      _animationController.forward(from: 0);
      navigationProvider.setIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final offsetAnimation =
              Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _screens[navigationProvider.currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  );
                }
                return TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: navigationProvider.currentIndex,
              onDestinationSelected: (index) => _onTap(index, navigationProvider),
              elevation: 0,
              height: 70,
              surfaceTintColor: Colors.transparent,
              backgroundColor: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
              shadowColor: Colors.transparent,
              destinations: [
                _buildNavDestination(
                  icon: LucideIcons.home,
                  selectedIcon: LucideIcons.home,
                  label: l10n.home,
                  index: 0,
                  currentIndex: navigationProvider.currentIndex,
                ),
                _buildNavDestination(
                  icon: LucideIcons.shoppingBag,
                  selectedIcon: LucideIcons.shoppingBag,
                  label: l10n.shop,
                  index: 1,
                  currentIndex: navigationProvider.currentIndex,
                ),
                _buildNavDestination(
                  icon: LucideIcons.heart,
                  selectedIcon: LucideIcons.heart,
                  label: l10n.wishlist,
                  index: 2,
                  currentIndex: navigationProvider.currentIndex,
                ),
                _buildNavDestination(
                  icon: LucideIcons.shoppingCart,
                  selectedIcon: LucideIcons.shoppingCart,
                  label: l10n.cart,
                  index: 3,
                  currentIndex: navigationProvider.currentIndex,
                ),
                _buildNavDestination(
                  icon: LucideIcons.user,
                  selectedIcon: LucideIcons.user,
                  label: l10n.profile,
                  index: 4,
                  currentIndex: navigationProvider.currentIndex,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required int currentIndex,
  }) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return NavigationDestination(
      icon: AnimatedScale(
        scale: isSelected ? _scaleAnimation.value : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          icon,
          size: isSelected ? 24 : 22,
          color: isSelected
              ? colorScheme.primary
              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
      ),
      selectedIcon: AnimatedScale(
        scale: _scaleAnimation.value,
        duration: const Duration(milliseconds: 200),
        child: Icon(selectedIcon, size: 24, color: colorScheme.primary),
      ),
      label: label,
    );
  }
}
