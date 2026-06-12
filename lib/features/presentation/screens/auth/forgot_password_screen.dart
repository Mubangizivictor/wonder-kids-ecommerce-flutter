import 'package:ecom/core/utils/animations.dart';
import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'widgets/auth_background.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/auth_button.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterEmailToReset)),
      );
      return;
    }

    try {
      await context.read<AuthProvider>().resetPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.resetLinkSent)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLoading = context.watch<AuthProvider>().isLoading;
    
    return AuthBackground(
      child: Column(
        children: [
          const SizedBox(height: 40),
          FadeInAnimation(
            delay: const Duration(milliseconds: 200),
            child: AuthHeader(
              title: l10n.forgotPasswordTitle,
              subtitle: l10n.forgotPasswordSubtitle,
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: FadeInAnimation(
              delay: const Duration(milliseconds: 400),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: theme.brightness == Brightness.dark 
                          ? Colors.black.withAlpha(120) 
                          : theme.colorScheme.primary.withAlpha(15),
                      blurRadius: 25,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _emailController,
                        label: l10n.emailAddress,
                        hint: l10n.exampleEmail,
                        prefixIcon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 40),
                      AuthButton(
                        text: l10n.sendResetLink,
                        onTap: _handleResetPassword,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.rememberPassword,
                            style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                              l10n.logIn,
                              style: TextStyle(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
