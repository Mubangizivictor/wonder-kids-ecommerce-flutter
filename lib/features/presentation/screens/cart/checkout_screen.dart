import 'package:ecom/features/domain/models/address_model.dart';
import 'package:ecom/features/domain/models/payment_method_model.dart';
import 'package:ecom/features/presentation/providers/address_provider.dart';
import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/features/presentation/providers/cart_provider.dart';
import 'package:ecom/features/presentation/providers/payment_provider.dart';
import 'package:ecom/features/presentation/screens/cart/payment_success_screen.dart';
import 'package:ecom/features/presentation/screens/cart/widgets/checkout/checkout_address_section.dart';
import 'package:ecom/features/presentation/screens/cart/widgets/checkout/checkout_payment_section.dart';
import 'package:ecom/features/presentation/screens/cart/widgets/checkout/checkout_summary_section.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'package:ecom/features/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethodModel? _selectedMethod;
  AddressModel? _selectedAddress;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final methods = context.read<PaymentProvider>().savedMethods;
    if (methods.isNotEmpty) {
      _selectedMethod = methods.first;
    }
    
    final addresses = context.read<AddressProvider>().addresses;
    if (addresses.isNotEmpty) {
      _selectedAddress = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currency = settingsProvider.currency;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final total = cartProvider.totalWithDelivery;

    String formatPrice(double price) {
      if (currency == 'USD') {
        double usdPrice = price / 3800;
        return '\$${usdPrice.toStringAsFixed(2)}';
      }
      return 'UGX ${price.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.checkout),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.chevronLeft),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckoutAddressSection(
                  selectedAddress: _selectedAddress,
                  onAddressSelected: (address) => setState(() => _selectedAddress = address),
                ),
                const SizedBox(height: 32),
                CheckoutPaymentSection(
                  selectedMethod: _selectedMethod,
                  onMethodSelected: (method) => setState(() => _selectedMethod = method),
                ),
                const SizedBox(height: 32),
                // Add a listener or Consumer here to update selection if it was null
                Consumer<PaymentProvider>(
                  builder: (context, paymentProvider, _) {
                    if (_selectedMethod == null && paymentProvider.savedMethods.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _selectedMethod == null) {
                          setState(() => _selectedMethod = paymentProvider.savedMethods.first);
                        }
                      });
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const CheckoutSummarySection(),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.payAmount(formatPrice(total)), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (_selectedMethod == null || _selectedAddress == null) return;

    final cartProvider = context.read<CartProvider>();
    final paymentProvider = context.read<PaymentProvider>();
    final authProvider = context.read<AuthProvider>();
    final total = cartProvider.totalWithDelivery;

    setState(() => _isProcessing = true);

    final success = await paymentProvider.processPayment(
      items: cartProvider.items.values.toList(),
      total: total,
      method: _selectedMethod!,
      address: '${_selectedAddress!.address}, ${_selectedAddress!.city}',
      userId: authProvider.currentUser?.uid,
    );

    if (success && mounted) {
      cartProvider.clearCart();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
          (route) => route.isFirst,
        );
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }
}
