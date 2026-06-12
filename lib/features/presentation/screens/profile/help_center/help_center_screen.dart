import 'package:ecom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpCenter),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.chevronLeft),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(LucideIcons.messageCircle, size: 40, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    l10n.howCanWeHelp,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.helpDesc,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.contactUs,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactTile(
              context, 
              LucideIcons.phone, 
              l10n.callSupport, 
              '+256 793 128137',
              onTap: () => _makePhoneCall('+256793128137'),
            ),
            _buildContactTile(
              context, 
              LucideIcons.mail, 
              l10n.emailUs, 
              'mubangizivic@gmail.com',
              onTap: () => _sendEmail('mubangizivic@gmail.com'),
            ),
            _buildContactTile(
              context, 
              LucideIcons.messageSquare, 
              l10n.liveChat, 
              l10n.startConversation,
              onTap: () {
                // For a real app, you'd navigate to a ChatScreen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Live Chat feature coming soon!')),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              l10n.faqs,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqTile(context, l10n.faq1, l10n.ans1),
            _buildFaqTile(context, l10n.faq2, l10n.ans2),
            _buildFaqTile(context, l10n.faq3, l10n.ans3),
            _buildFaqTile(context, l10n.faq4, l10n.ans4),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(LucideIcons.chevronRight, size: 18),
      onTap: onTap,
    );
  }

  Widget _buildFaqTile(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            answer,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
