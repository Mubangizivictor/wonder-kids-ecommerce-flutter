import 'package:ecom/features/presentation/providers/auth_provider.dart';
import 'package:ecom/features/presentation/screens/auth/login_screen.dart';
import 'package:ecom/core/theme/app_colors.dart';
import 'package:ecom/core/providers/navigation_provider.dart';
import 'package:ecom/features/presentation/providers/product_provider.dart';
import 'package:ecom/features/presentation/providers/settings_provider.dart';
import 'package:ecom/features/presentation/screens/product/widgets/product_card_vertical.dart';
import 'package:ecom/core/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/domain/models/product_model.dart';
import 'package:ecom/features/presentation/providers/cart_provider.dart';
import 'package:ecom/features/presentation/providers/wishlist_provider.dart';
import 'package:ecom/features/presentation/providers/review_provider.dart';
import 'package:ecom/features/presentation/providers/order_provider.dart';
import 'package:ecom/features/domain/models/review_model.dart';
import 'package:ecom/features/domain/models/order_model.dart';
import 'package:ecom/shared_widgets/custom_elevated_button.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ecom/features/presentation/screens/cart/checkout_screen.dart';
import 'package:ecom/l10n/app_localizations.dart';

import 'widgets/details/product_image_carousel.dart';
import 'widgets/details/product_info_section.dart';
import 'widgets/details/product_selection_section.dart';
import 'widgets/details/product_delivery_info.dart';
import 'widgets/details/product_description_section.dart';
import 'widgets/details/product_review_section.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  String? _selectedColor;
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    if (widget.product.productColors.isNotEmpty) {
      _selectedColor = widget.product.productColors.first;
    }
    if (widget.product.productSizes.isNotEmpty) {
      _selectedSize = widget.product.productSizes.first;
    }
    
    Future.microtask(() {
      if (mounted) {
        context.read<ReviewProvider>().fetchReviews(widget.product.id);
        context.read<OrderProvider>().startUserOrderListener(
          context.read<AuthProvider>().currentUser?.uid ?? ''
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    
    final product = productProvider.products.firstWhere(
      (p) => p.id == widget.product.id, 
      orElse: () => widget.product
    );

    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currency = settingsProvider.currency;
    final languageCode = Localizations.localeOf(context).languageCode;
    final relatedProducts = productProvider.products
        .where((p) => p.category == product.category && p.id != product.id)
        .toList();

    final isWishlisted = wishlistProvider.isFavorite(product.id);
    final isInCart = cartProvider.isInCart(product.id);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context);

    bool hasPurchased = authProvider.isAuthenticated && 
      orderProvider.userOrders.any((order) => 
        order.items.any((item) => item.product.id == product.id) &&
        order.status == OrderStatus.delivered
      );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, product, isDark, isWishlisted, authProvider, wishlistProvider, currency),
          SliverToBoxAdapter(
            child: FadeInAnimation(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductInfoSection(
                    product: product, 
                    currency: currency, 
                    languageCode: languageCode
                  ),
                  const Divider(thickness: 8, color: AppColors.dividerLight),
                  ProductSelectionSection(
                    product: product,
                    selectedColor: _selectedColor,
                    selectedSize: _selectedSize,
                    onColorSelected: (val) => setState(() => _selectedColor = val),
                    onSizeSelected: (val) => setState(() => _selectedSize = val),
                  ),
                  const Divider(thickness: 8, color: AppColors.dividerLight),
                  const ProductDeliveryInfo(),
                  const Divider(thickness: 8, color: AppColors.dividerLight),
                  _buildQuantitySection(theme, l10n, product),
                  const Divider(thickness: 8, color: AppColors.dividerLight),
                  ProductDescriptionSection(
                    description: product.getLocalizedDescription(languageCode)
                  ),
                  if (relatedProducts.isNotEmpty) ...[
                    const Divider(thickness: 8, color: AppColors.dividerLight),
                    _buildRelatedProducts(theme, relatedProducts),
                  ],
                  const Divider(thickness: 8, color: AppColors.dividerLight),
                  ProductReviewSection(
                    product: product,
                    hasPurchased: hasPurchased,
                    onWriteReview: () => _showWriteReviewSheet(context),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomSheet(theme, isDark, product, isInCart, l10n, authProvider, cartProvider),
    );
  }

  Widget _buildAppBar(BuildContext context, ProductModel product, bool isDark, bool isWishlisted, AuthProvider auth, WishlistProvider wishlist, String currency) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.45,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: _buildAppBarAction(
        icon: LucideIcons.chevronLeft,
        isDark: isDark,
        onTap: () => Navigator.pop(context),
      ),
      actions: [
        _buildAppBarAction(
          icon: LucideIcons.share2,
          isDark: isDark,
          onTap: () {
            final String text = 'Check out this ${product.title} on Wonder Kids!\n\n${product.getFormattedPrice(currency)}\n\n${product.imgUrl}';
            Share.share(text, subject: product.title);
          },
        ),
        _buildAppBarAction(
          icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
          iconColor: isWishlisted ? const Color(0xFFF06292) : null,
          isDark: isDark,
          onTap: () {
            if (!auth.isAuthenticated) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              return;
            }
            wishlist.toggleWishlist(product);
          },
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: ProductImageCarousel(product: product),
      ),
    );
  }

  Widget _buildAppBarAction({required IconData icon, required bool isDark, required VoidCallback onTap, Color? iconColor}) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withAlpha(150) : Colors.white.withAlpha(200),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor ?? (isDark ? Colors.white : Colors.black87)),
      ),
      onPressed: onTap,
    );
  }

  Widget _buildQuantitySection(ThemeData theme, AppLocalizations l10n, ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                product.isInStock ? 'In Stock' : 'Out of Stock',
                style: TextStyle(
                  color: product.isInStock ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l10n.quantity, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 24),
              _buildQuantitySelector(theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
            icon: Icon(LucideIcons.minus, size: 16, color: _quantity > 1 ? theme.colorScheme.primary : Colors.grey),
          ),
          SizedBox(
            width: 30,
            child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          IconButton(
            onPressed: () => setState(() => _quantity++),
            icon: Icon(LucideIcons.plus, size: 16, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts(ThemeData theme, List<ProductModel> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Related Products', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 380,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: products.length,
            itemBuilder: (context, index) => SizedBox(
              width: 200,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ProductCardVertical(product: products[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSheet(ThemeData theme, bool isDark, ProductModel product, bool isInCart, AppLocalizations l10n, AuthProvider auth, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: !product.isInStock ? null : () {
                if (isInCart) {
                  context.read<NavigationProvider>().setIndex(3);
                  Navigator.popUntil(context, (route) => route.isFirst);
                  return;
                }
                if (!auth.isAuthenticated) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  return;
                }
                cart.addItem(product, quantity: _quantity, color: _selectedColor, size: _selectedSize);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 56),
                side: BorderSide(color: isInCart ? AppColors.success : theme.colorScheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                isInCart ? 'View Cart' : l10n.addToCart,
                style: TextStyle(color: isInCart ? AppColors.success : theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomElevatedButton(
              text: product.isInStock ? 'Buy Now' : 'Out of Stock',
              onPressed: !product.isInStock ? null : () {
                if (!auth.isAuthenticated) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  return;
                }
                if (!isInCart) cart.addItem(product, quantity: _quantity, color: _selectedColor, size: _selectedSize);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showWriteReviewSheet(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final reviewProvider = context.read<ReviewProvider>();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController commentController = TextEditingController();
    double selectedRating = 5.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Write a Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: List.generate(5, (index) {
                  final val = index + 1.0;
                  return IconButton(
                    icon: Icon(LucideIcons.star, color: val <= selectedRating ? AppColors.rating : AppColors.starGrey),
                    onPressed: () => setModalState(() => selectedRating = val),
                  );
                }),
              ),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 16),
              TextField(controller: commentController, maxLines: 4, decoration: const InputDecoration(labelText: 'Comment')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.isEmpty || titleController.text.isEmpty) return;
                    await reviewProvider.addReview(ReviewModel(
                      id: '',
                      userId: authProvider.currentUser?.uid ?? '',
                      userName: authProvider.currentUser?.displayName ?? 'Valued Customer',
                      productId: widget.product.id,
                      rating: selectedRating,
                      title: titleController.text,
                      comment: commentController.text,
                      date: DateTime.now(),
                    ));
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Submit Review'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
