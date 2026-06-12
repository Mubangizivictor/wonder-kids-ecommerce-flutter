import 'package:ecom/core/theme/theme_provider.dart';
import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import 'widgets/settings_tile.dart';
import 'widgets/notification_settings_section.dart';
import 'widgets/preferences_section.dart';
import '../profile/widgets/profile_section.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountSettings),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(20.0),
            child: Column(
              children: [
                NotificationSettingsSection(
                  pushNotifications: settingsProvider.pushNotifications,
                  emailMarketing: settingsProvider.emailMarketing,
                  onPushChanged: (v) => settingsProvider.togglePushNotifications(v),
                  onEmailChanged: (v) => settingsProvider.toggleEmailMarketing(v),
                ),
                PreferencesSection(
                  currency: settingsProvider.currency,
                  isDarkMode: themeProvider.isDark,
                  onCurrencyTap: () => _showCurrencyPicker(context, settingsProvider),
                  onThemeChanged: (v) => themeProvider.toggleTheme(),
                ),
                ProfileSection(
                  title: l10n.accountActions,
                  children: [
                    SettingsTile(
                      icon: LucideIcons.trash2,
                      title: l10n.deleteAccount,
                      iconColor: Colors.redAccent,
                      onTap: authProvider.isLoading ? null : () => _showDeleteAccountDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (authProvider.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, SettingsProvider settingsProvider) {
    final currencies = ['UGX', 'USD'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.currency,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  return ListTile(
                    title: Text(currency),
                    trailing: settingsProvider.currency == currency
                        ? const Icon(LucideIcons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      settingsProvider.setCurrency(currency);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteAccount, style: const TextStyle(color: Colors.redAccent)),
        content: Text(
          l10n.deleteAccountWarning,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await context.read<AuthProvider>().deleteAccount();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              } catch (e) {
                if (context.mounted) {
                  String message = e.toString();
                  if (message.contains('requires-recent-login')) {
                    message = l10n.reloginToDelete;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              }
            },
            child: Text(
              l10n.confirmDelete,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
