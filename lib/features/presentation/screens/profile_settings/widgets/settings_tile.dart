// ignore_for_file: deprecated_member_use, unreachable_switch_default

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum SettingsTileType { chevron, switchButton, text }

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final SettingsTileType type;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;
  final Color? iconColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.type = SettingsTileType.chevron,
    this.switchValue = false,
    this.onSwitchChanged,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: type == SettingsTileType.switchButton ? null : onTap,
      leading: Icon(
        icon,
        size: 20,
        color: iconColor ?? theme.colorScheme.onSurface.withAlpha(179),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _buildTrailing(theme),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildTrailing(ThemeData theme) {
    switch (type) {
      case SettingsTileType.switchButton:
        return Switch.adaptive(
          value: switchValue,
          onChanged: onSwitchChanged,
          activeColor: theme.colorScheme.primary,
        );
      case SettingsTileType.text:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              Text(
                value!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: theme.textTheme.bodySmall?.color?.withAlpha(102),
            ).animateRTL,
          ],
        );
      case SettingsTileType.chevron:
      default:
        return Icon(
          LucideIcons.chevronRight,
          size: 18,
          color: theme.textTheme.bodySmall?.color?.withAlpha(102),
        ).animateRTL;
    }
  }
}

extension on Widget {
  Widget get animateRTL => Builder(
        builder: (context) {
          if (Directionality.of(context) == TextDirection.rtl) {
            return Transform.flip(flipX: true, child: this);
          }
          return this;
        },
      );
}
