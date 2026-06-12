import 'package:ecom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'settings_tile.dart';
import '../../profile/widgets/profile_section.dart';

class PreferencesSection extends StatelessWidget {
  final String currency;
  final bool isDarkMode;
  final VoidCallback onCurrencyTap;
  final ValueChanged<bool> onThemeChanged;

  const PreferencesSection({
    super.key,
    required this.currency,
    required this.isDarkMode,
    required this.onCurrencyTap,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ProfileSection(
      title: l10n.preferences,
      children: [
        SettingsTile(
          icon: LucideIcons.banknote,
          title: l10n.currency,
          type: SettingsTileType.text,
          value: currency,
          onTap: onCurrencyTap,
        ),
        const Divider(height: 1, indent: 50),
        SettingsTile(
          icon: LucideIcons.moon,
          title: l10n.darkMode,
          type: SettingsTileType.switchButton,
          switchValue: isDarkMode,
          onSwitchChanged: onThemeChanged,
        ),
      ],
    );
  }
}
