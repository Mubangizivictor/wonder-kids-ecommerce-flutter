import 'package:ecom/core/utils/whatsapp_helper.dart';
import 'package:ecom/features/presentation/providers/address_provider.dart';
import 'package:ecom/features/presentation/screens/cart/checkout_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/presentation/providers/cart_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../l10n/app_localizations.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cartProvider = Provider.of<CartProvider>(context);
    final addressProvider = Provider.of<AddressProvider>(context);

    final subtotal = cartProvider.subtotal;
    final delivery = cartProvider.deliveryFee;
    final total = cartProvider.totalWithDelivery;

    String formatPrice(double price) {
      return 'UGX ${price.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subtotal < CartProvider.freeDeliveryThreshold)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Add UGX ${formatPrice(CartProvider.freeDeliveryThreshold - subtotal).replaceAll('UGX ', '')} more for FREE delivery!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            _buildSummaryRow(l10n.subtotal, formatPrice(subtotal), theme),
            const SizedBox(height: 8),
            _buildSummaryRow(
              l10n.delivery,
              delivery == 0 ? 'FREE' : formatPrice(delivery),
              theme,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            _buildSummaryRow(l10n.total, formatPrice(total), theme, isTotal: true),
            const SizedBox(height: 24),
            Row(
              children: [
                // Phone Call Button
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => launchUrl(
                      Uri.parse('tel:${WhatsAppHelper.phoneNumber}'),
                      mode: LaunchMode.externalApplication,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                      elevation: 0,
                      minimumSize: const Size(56, 56),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(LucideIcons.phone, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                // WhatsApp Icon Button
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withAlpha(40),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: subtotal > 0
                        ? () {
                            final defaultAddress = addressProvider.addresses.isEmpty 
                                ? null 
                                : addressProvider.addresses.firstWhere(
                                    (a) => a.isDefault,
                                    orElse: () => addressProvider.addresses.first,
                                  );
                            
                            WhatsAppHelper.launchWhatsAppOrder(
                              items: cartProvider.items.values.toList(),
                              total: total,
                              delivery: delivery,
                              address: defaultAddress != null 
                                  ? "${defaultAddress.address}, ${defaultAddress.city}" 
                                  : null,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF25D366,
                      ), // WhatsApp Green
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(56, 56),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const FaIcon(FontAwesomeIcons.whatsapp, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                // Checkout Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: subtotal > 0
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CheckoutScreen(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.checkoutNow,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildSummaryRow(
    String label,
    String value,
    ThemeData theme, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )
              : theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
        ),
      ],
    );
  }
}
