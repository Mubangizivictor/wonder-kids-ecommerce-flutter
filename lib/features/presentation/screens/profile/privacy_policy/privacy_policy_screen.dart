import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ecom/l10n/app_localizations.dart';

class LegalScreen extends StatefulWidget {
  final bool showTerms;
  const LegalScreen({super.key, this.showTerms = false});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.showTerms ? 1 : 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_tabController.index == 0 ? l10n.privacyPolicy : l10n.termsConditions),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() {}),
          tabs: [
            Tab(text: l10n.privacyPolicy),
            Tab(text: l10n.termsConditions),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrivacyPolicy(theme),
          _buildTermsAndConditions(theme),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Privacy Policy', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Your privacy is important to us. It is Wonder Kids\' policy to respect your privacy regarding any information we may collect from you through our app and other sites we own and operate.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
          const SizedBox(height: 24),
          _buildSection(theme, '1. Information We Collect', 
            'We only ask for personal information when we truly need it to provide a service to you. We collect it by fair and lawful means, with your knowledge and consent. We also let you know why we’re collecting it and how it will be used.\n\nSpecifically, we collect:\n• Name and Contact Details\n• Shipping and Billing Addresses\n• Phone Number for delivery coordination\n• Device information for app optimization'),
          _buildSection(theme, '2. Data Retention', 
            'We only retain collected information for as long as necessary to provide you with your requested service. What data we store, we’ll protect within commercially acceptable means to prevent loss and theft, as well as unauthorized access, disclosure, copying, use or modification.'),
          _buildSection(theme, '3. Data Sharing', 
            'We don’t share any personally identifying information publicly or with third-parties, except when required to by law, or when necessary to fulfill your order (e.g., sharing your address with our delivery partners MTN, Airtel, or local couriers).'),
          _buildSection(theme, '4. Your Rights', 
            'You are free to refuse our request for your personal information, with the understanding that we may be unable to provide you with some of your desired services. You have the right to delete your account and all associated data at any time via the account settings.'),
          _buildSection(theme, '5. Contact Us', 
            'If you have any questions about how we handle user data and personal information, feel free to contact us at mubangizivic@gmail.com.'),
          const SizedBox(height: 40),
          Center(
            child: Text('Last updated: June 2024', style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Terms & Conditions', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Welcome to Wonder Kids. By using our application, you agree to the following terms and conditions.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
          const SizedBox(height: 24),
          _buildSection(theme, '1. User Account', 
            'To access certain features of the app, you must register for an account. You are responsible for maintaining the confidentiality of your account password and for all activities that occur under your account.'),
          _buildSection(theme, '2. Purchasing and Payment', 
            'All purchases are subject to availability. We accept various payment methods including Mobile Money (MTN & Airtel) and Credit/Debit Cards. Prices are displayed in UGX (Uganda Shillings) by default.'),
          _buildSection(theme, '3. Shipping and Delivery', 
            'We aim to deliver within 24-48 hours within Kampala and 3-5 days upcountry. Orders over UGX 100,000 qualify for FREE delivery. A standard delivery fee of UGX 15,000 applies to orders below this threshold. Wonder Kids is not responsible for delays beyond our control.'),
          _buildSection(theme, '4. Returns and Refunds', 
            'Items can be returned within 7 days of delivery if they are in their original, unused condition and packaging. Refunds will be processed back to the original payment method or as store credit.'),
          _buildSection(theme, '5. Prohibited Conduct', 
            'You agree not to use the app for any unlawful purpose or in any way that interrupts, damages, or impairs the service.'),
          _buildSection(theme, '6. Governing Law', 
            'These terms are governed by and construed in accordance with the laws of Uganda.'),
          const SizedBox(height: 40),
          Center(
            child: Text('Last updated: June 2024', style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          Text(content, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}

// Keep the old name for compatibility or rename all usages
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) => const LegalScreen(showTerms: false);
}
