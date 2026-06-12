import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/settings_provider.dart';

class CheckoutSummarySection extends StatelessWidget {
  const CheckoutSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cartProvider = Provider.of<CartProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currency = settingsProvider.currency;

    final subtotal = cartProvider.subtotal;
    final delivery = cartProvider.deliveryFee;
    final total = cartProvider.totalWithDelivery;

    String formatPrice(double price) {
      if (currency == 'USD') {
        double usdPrice = price / 3800;
        return '\$${usdPrice.toStringAsFixed(2)}';
      }
      return 'UGX ${price.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, l10n.orderSummary),
        const SizedBox(height: 12),
        _summaryRow(l10n.subtotal, formatPrice(subtotal), theme),
        const SizedBox(height: 8),
        _summaryRow(l10n.delivery, delivery == 0 ? l10n.free : formatPrice(delivery), theme),
        const Divider(height: 32),
        _summaryRow(l10n.total, formatPrice(total), theme, isTotal: true),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _summaryRow(String label, String value, ThemeData theme, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null),
        Text(value, style: isTotal ? TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 18) : null),
      ],
    );
  }
}
