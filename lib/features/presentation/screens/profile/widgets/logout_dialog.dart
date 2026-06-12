import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/features/presentation/screens/root_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to log out of your account?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await context.read<AuthProvider>().signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const RootScreen()),
                (route) => false,
              );
            }
          },
          child: const Text(
            'Log Out',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
