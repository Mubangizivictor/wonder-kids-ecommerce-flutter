import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../domain/models/payment_method_model.dart';
import '../../../../providers/payment_provider.dart';
import '../../../profile/payment_methods/payment_methods_screen.dart';
import '../../../profile/payment_methods/widgets/payment_method_tile.dart';

class CheckoutPaymentSection extends StatelessWidget {
  final PaymentMethodModel? selectedMethod;
  final Function(PaymentMethodModel) onMethodSelected;

  const CheckoutPaymentSection({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, l10n.paymentMethod),
        const SizedBox(height: 12),
        if (paymentProvider.savedMethods.isEmpty)
          _buildAddPaymentPrompt(context, theme, l10n)
        else
          ...paymentProvider.savedMethods.map((method) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PaymentMethodTile(
                  method: method,
                  isSelected: selectedMethod?.id == method.id,
                  onTap: () => onMethodSelected(method),
                ),
              )),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAddPaymentPrompt(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.primary.withAlpha(100), width: 1.5),
          color: theme.colorScheme.primary.withAlpha(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.plus, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.addPaymentMethod,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    l10n.noPaymentMethodSelected,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight),
          ],
        ),
      ),
    );
  }
}
