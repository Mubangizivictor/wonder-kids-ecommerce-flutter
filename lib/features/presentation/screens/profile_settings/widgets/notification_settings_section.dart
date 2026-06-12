import 'package:ecom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'settings_tile.dart';
import '../../profile/widgets/profile_section.dart';

class NotificationSettingsSection extends StatelessWidget {
  final bool pushNotifications;
  final bool emailMarketing;
  final ValueChanged<bool> onPushChanged;
  final ValueChanged<bool> onEmailChanged;

  const NotificationSettingsSection({
    super.key,
    required this.pushNotifications,
    required this.emailMarketing,
    required this.onPushChanged,
    required this.onEmailChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ProfileSection(
      title: l10n.notifications,
      children: [
        SettingsTile(
          icon: LucideIcons.bell,
          title: l10n.pushNotifications,
          type: SettingsTileType.switchButton,
          switchValue: pushNotifications,
          onSwitchChanged: onPushChanged,
        ),
        const Divider(height: 1, indent: 50),
        SettingsTile(
          icon: LucideIcons.mail,
          title: l10n.emailMarketing,
          type: SettingsTileType.switchButton,
          switchValue: emailMarketing,
          onSwitchChanged: onEmailChanged,
        ),
      ],
    );
  }
}
