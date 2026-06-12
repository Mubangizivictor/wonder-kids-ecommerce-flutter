import 'package:ecom/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:ecom/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../auth/widgets/auth_background.dart';
import '../auth/widgets/auth_button.dart';
import '../auth/widgets/social_auth_button.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../root_screen.dart';
import 'widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    // Use theme's onSurface instead of a hardcoded constant for better contrast
    final textColor = theme.colorScheme.onSurface;

    return AuthBackground(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _isLastPage = index == 2;
                  });
                },
                children: [
                  OnboardingPage(
                    title: l10n.onboardingTitle1,
                    description: l10n.onboardingDesc1,
                    animationPath: 'assets/animations/luxury_collections.json',
                    isLottie: true,
                  ),
                  OnboardingPage(
                    title: l10n.onboardingTitle2,
                    description: l10n.onboardingDesc2,
                    animationPath: 'assets/animations/premium_quality.json',
                    isLottie: true,
                  ),
                  OnboardingPage(
                    title: l10n.onboardingTitle3,
                    description: l10n.onboardingDesc3,
                    animationPath: 'assets/animations/delivery.json',
                    isLottie: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      activeDotColor: theme.colorScheme.primary,
                      dotColor: theme.colorScheme.primary.withAlpha(isDark ? 40 : 60), // Adjusted dot alpha
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthButton(
                    text: _isLastPage ? l10n.getStarted : l10n.next,
                    onTap: () async {
                      if (_isLastPage) {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.setHasSeenOnboarding();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const RootScreen()),
                          );
                        }
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Divider(color: textColor.withAlpha(isDark ? 30 : 50))), // Softer dividers
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.logInWith,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: textColor.withAlpha(isDark ? 120 : 150),
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: textColor.withAlpha(isDark ? 30 : 50))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialAuthButton(
                        iconUrl: 'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                        onTap: () {},
                      ),
                      const SizedBox(width: 20),
                      SocialAuthButton(
                        iconUrl: 'https://cdn-icons-png.flaticon.com/512/0/747.png',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textColor.withAlpha(isDark ? 120 : 150),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          l10n.logIn,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
