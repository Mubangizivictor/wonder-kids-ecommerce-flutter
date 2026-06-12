import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/domain/models/address_model.dart';
import 'package:ecom/features/presentation/providers/address_provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'package:ecom/features/presentation/screens/profile/shipping_addresses/shipping_addresses_screen.dart';

class CheckoutAddressSection extends StatelessWidget {
  final AddressModel? selectedAddress;
  final Function(AddressModel) onAddressSelected;

  const CheckoutAddressSection({
    super.key,
    required this.selectedAddress,
    required this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final addressProvider = Provider.of<AddressProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, l10n.shippingAddress),
        const SizedBox(height: 12),
        _buildAddressCard(context, theme, addressProvider, l10n),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAddressCard(BuildContext context, ThemeData theme, AddressProvider addressProvider, AppLocalizations l10n) {
    if (selectedAddress == null) {
      return InkWell(
        onTap: () => _showChangeAddressSheet(context, theme, addressProvider, l10n),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.error.withAlpha(100)),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.mapPin, color: theme.colorScheme.error),
              const SizedBox(width: 16),
              Text(l10n.pleaseSelectAddress),
              const Spacer(),
              const Icon(LucideIcons.chevronRight),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.mapPin, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(selectedAddress!.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${selectedAddress!.address}, ${selectedAddress!.city}', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showChangeAddressSheet(context, theme, addressProvider, l10n),
            child: Text(l10n.change),
          ),
        ],
      ),
    );
  }

  void _showChangeAddressSheet(BuildContext context, ThemeData theme, AddressProvider addressProvider, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.selectShippingAddress, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (addressProvider.addresses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(l10n.noAddressesFound, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: addressProvider.addresses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final address = addressProvider.addresses[index];
                    return InkWell(
                      onTap: () {
                        onAddressSelected(address);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedAddress?.id == address.id ? theme.colorScheme.primary : theme.dividerColor.withAlpha(50),
                            width: selectedAddress?.id == address.id ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(address.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${address.address}, ${address.city}', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShippingAddressesScreen()),
                );
              },
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(l10n.addManageAddresses),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
