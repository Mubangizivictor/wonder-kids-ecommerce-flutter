// ignore_for_file: unused_import

import 'package:ecom/core/utils/animations.dart';
import 'package:ecom/core/theme/app_colors.dart';
import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/features/presentation/screens/root_screen.dart';
import 'package:ecom/features/presentation/screens/profile/privacy_policy/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'widgets/auth_background.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/auth_button.dart';
import 'widgets/social_auth_button.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseAgreeTerms),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordsDoNotMatch),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseFillFields),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RootScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final goldColor = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final isLoading = context.watch<AuthProvider>().isLoading;

    return AuthBackground(
      child: Column(
        children: [
          const SizedBox(height: 40),
          FadeInAnimation(
            delay: const Duration(milliseconds: 200),
            child: AuthHeader(
              title: l10n.createAccount,
              subtitle: l10n.signUpSubtitle,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: FadeInAnimation(
              delay: const Duration(milliseconds: 400),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withAlpha(50) : theme.colorScheme.primary.withAlpha(15),
                      blurRadius: 30,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthTextField(
                        controller: _nameController,
                        label: l10n.fullName,
                        hint: l10n.enterFullName,
                        prefixIcon: LucideIcons.user,
                      ),
                      const SizedBox(height: 25),
                      AuthTextField(
                        controller: _emailController,
                        label: l10n.emailAddress,
                        hint: l10n.enterEmail,
                        prefixIcon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 25),
                      AuthTextField(
                        controller: _passwordController,
                        label: l10n.password,
                        hint: l10n.createPassword,
                        prefixIcon: LucideIcons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 25),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: l10n.confirmPassword,
                        hint: l10n.confirmYourPassword,
                        prefixIcon: LucideIcons.shieldCheck,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                              activeColor: goldColor,
                              side: BorderSide(
                                color: onSurface.withAlpha(100), 
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Wrap(
                                children: [
                                  Text(
                                    l10n.agreeToTerms,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: onSurface.withAlpha(150),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LegalScreen(showTerms: true),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      l10n.termsConditions,
                                      style: TextStyle(
                                        color: goldColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    l10n.and,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: onSurface.withAlpha(150),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LegalScreen(showTerms: false),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      l10n.privacyPolicyLink,
                                      style: TextStyle(
                                        color: goldColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      AuthButton(
                        text: l10n.signUp,
                        onTap: _handleSignup,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(child: Divider(color: onSurface.withAlpha(50))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              l10n.orSignUpWith,
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: onSurface.withAlpha(100),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: onSurface.withAlpha(50))),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SocialAuthButton(
                            iconUrl: 'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                            onTap: () {},
                          ),
                          const SizedBox(width: 25),
                          SocialAuthButton(
                            iconUrl: 'https://cdn-icons-png.flaticon.com/512/0/747.png',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.alreadyHaveAccount,
                            style: GoogleFonts.poppins(
                              color: onSurface.withAlpha(150),
                              fontSize: 14,
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
                              style: GoogleFonts.poppins(
                                color: goldColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
