// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'widgets/auth_background.dart';
import 'widgets/auth_button.dart';
import 'widgets/social_auth_button.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AuthBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Column(
          children: [
            const Spacer(),
            // Big Hero Image / Illustration Placeholder
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=2600&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(50),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            AuthButton(
              text: 'Get Started',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white.withAlpha(50))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Log in with',
                    style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12),
                  ),
                ),
                Expanded(child: Divider(color: Colors.white.withAlpha(50))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SocialAuthButton(
                  iconUrl: 'https://cdn-icons-png.flaticon.com/512/2991/2991148.png', // Google
                  onTap: () {},
                ),
                const SizedBox(width: 20),
                SocialAuthButton(
                  iconUrl: 'https://cdn-icons-png.flaticon.com/512/0/747.png', // Apple
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.white.withAlpha(150)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                  child: Text(
                    'Sign Up',
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
    );
  }
}
