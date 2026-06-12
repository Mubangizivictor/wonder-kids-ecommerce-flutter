import 'package:ecom/core/providers/navigation_provider.dart';
import 'package:ecom/core/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecom/l10n/app_localizations.dart';

/// A promotional banner displayed on the home screen.
/// Designed with a luxury gradient and decorative elements.
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    // Wonder Kids Playful Palette
    final primaryPink = theme.colorScheme.primary;
    final secondaryBlue = theme.colorScheme.secondary;
    
    return FadeInAnimation(
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: GestureDetector(
          onTap: () {
            Provider.of<NavigationProvider>(context, listen: false).navigateToShop();
          },
          child: Container(
            width: double.infinity,
            height: 140,
            clipBehavior: Clip.antiAlias, // Ensures the image respects the border radius
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryPink, secondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: primaryPink.withAlpha(isDark ? 50 : 30),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative Background Image - Positioned to the trailing side
                PositionedDirectional(
                  end: -15,
                  bottom: -15,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(Directionality.of(context) == TextDirection.rtl ? 3.14159 : 0),
                    child: Image.asset(
                      'assets/images/kids_banner.png',
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.promoTitle.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white.withAlpha(200),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.promoSubtitle.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              letterSpacing: 0.5,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // CTA Button
                          IntrinsicWidth(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(isDark ? 200 : 150),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.shopNow,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
