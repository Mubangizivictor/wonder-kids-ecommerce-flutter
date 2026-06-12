import 'package:ecom/core/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../../shared_widgets/theme_switch.dart';
import '../../../../../shared_widgets/notification_icon.dart';

/// The premium AppBar for the Home screen.
/// Features a personalized greeting, user profile, and quick actions.
class HomeAppbar extends StatelessWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final l10n = AppLocalizations.of(context)!;

    // Logic for time-based greeting
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return l10n.goodMorning;
      if (hour < 17) return l10n.goodAfternoon;
      return l10n.goodEvening;
    }

    return FadeInAnimation(
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 5, 12, 5),
        child: Row(
          children: [
            // Greeting and Username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.displayName ?? l10n.guestUser,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    getGreeting(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            
            // Actions Row
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ThemeSwitch(),
                const SizedBox(width: 4),
                const NotificationIcon(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
