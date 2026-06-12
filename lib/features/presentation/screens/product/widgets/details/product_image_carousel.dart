import 'package:flutter/material.dart';
import 'package:ecom/features/domain/models/product_model.dart';

class ProductImageCarousel extends StatefulWidget {
  final ProductModel product;

  const ProductImageCarousel({super.key, required this.product});

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = widget.product.productImages.isNotEmpty 
        ? widget.product.productImages 
        : [widget.product.imgUrl];

    return Stack(
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (index) => setState(() => _currentImageIndex = index),
          itemBuilder: (context, index) {
            return Hero(
              tag: 'product_image_${widget.product.id}_$index',
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? theme.colorScheme.primary
                        : Colors.white.withAlpha(150),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
