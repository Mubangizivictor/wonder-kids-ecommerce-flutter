// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'widgets/auth_background.dart';
import 'widgets/auth_header.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/auth_button.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AuthBackground(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const AuthHeader(
            title: 'New Password',
            subtitle: 'Your new password must be different from previous used passwords.',
          ),
          const SizedBox(height: 40),
          Expanded(
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
                    const AuthTextField(
                      label: 'New Password',
                      hint: 'xxxxxxxx',
                      prefixIcon: LucideIcons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),
                    const AuthTextField(
                      label: 'Confirm Password',
                      hint: 'xxxxxxxx',
                      prefixIcon: LucideIcons.shieldCheck,
                      isPassword: true,
                    ),
                    const SizedBox(height: 40),
                    AuthButton(
                      text: 'Reset Password',
                      onTap: () {
                        // Success Dialog or Navigate to Login
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text('Success'),
                            content: const Text('Your password has been reset successfully.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                },
                                child: const Text('Login Now'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
