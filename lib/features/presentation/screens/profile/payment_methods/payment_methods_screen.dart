import 'package:ecom/features/domain/models/payment_method_model.dart';
import 'package:ecom/features/presentation/providers/payment_provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'widgets/payment_method_tile.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paymentMethods),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.chevronLeft),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.paymentMethodsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: paymentProvider.savedMethods.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final method = paymentProvider.savedMethods[index];
                  return PaymentMethodTile(
                    method: method,
                    onDelete: () => _showDeleteConfirmation(context, method.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAddPaymentMethodSheet(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(LucideIcons.plus, size: 20),
              label: const Text('Add New Method'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String methodId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PaymentProvider>().deletePaymentMethod(methodId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentMethodSheet(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    PaymentType selectedType = PaymentType.card;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Payment Method',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<PaymentType>(
                initialValue: selectedType,
                decoration: InputDecoration(
                  labelText: 'Method Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  const DropdownMenuItem(value: PaymentType.card, child: Text('Credit/Debit Card')),
                  const DropdownMenuItem(value: PaymentType.mtn, child: Text('MTN Mobile Money')),
                  const DropdownMenuItem(value: PaymentType.airtel, child: Text('Airtel Money')),
                ],
                onChanged: (v) => setModalState(() => selectedType = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: selectedType == PaymentType.card ? 'Cardholder Name' : 'Account Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subtitleController,
                decoration: InputDecoration(
                  labelText: selectedType == PaymentType.card ? 'Card Number (**** **** **** 1234)' : 'Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty || subtitleController.text.isEmpty) return;

                  final newMethod = PaymentMethodModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: selectedType == PaymentType.card ? 'Visa Card' : titleController.text,
                    subtitle: subtitleController.text,
                    icon: selectedType == PaymentType.card ? Icons.credit_card : Icons.phone_android,
                    type: selectedType,
                    lastFour: selectedType == PaymentType.card ? subtitleController.text.substring(subtitleController.text.length - 4) : null,
                  );

                  context.read<PaymentProvider>().addPaymentMethod(newMethod);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Add Method'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
