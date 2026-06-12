import 'package:flutter/material.dart';
import 'package:ecom/features/domain/models/product_model.dart';

class ProductSelectionSection extends StatefulWidget {
  final ProductModel product;
  final String? selectedColor;
  final String? selectedSize;
  final Function(String) onColorSelected;
  final Function(String) onSizeSelected;

  const ProductSelectionSection({
    super.key,
    required this.product,
    this.selectedColor,
    this.selectedSize,
    required this.onColorSelected,
    required this.onSizeSelected,
  });

  @override
  State<ProductSelectionSection> createState() => _ProductSelectionSectionState();
}

class _ProductSelectionSectionState extends State<ProductSelectionSection> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.product.productColors.isEmpty && widget.product.productSizes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color Selection
          if (widget.product.productColors.isNotEmpty) ...[
            Text(
              'Color: ${widget.selectedColor}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.product.productColors.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final colorName = widget.product.productColors[index];
                  final isSelected = widget.selectedColor == colorName;
                  final displayColor = _getColorFromName(colorName);

                  return GestureDetector(
                    onTap: () => widget.onColorSelected(colorName),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: displayColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: displayColor == Colors.white ? Colors.grey.shade300 : Colors.transparent,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 14,
                                color: _getIconColor(displayColor, colorName),
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Size Selection
          if (widget.product.productSizes.isNotEmpty) ...[
            Text(
              'Size: ${widget.selectedSize}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.product.productSizes.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final size = widget.product.productSizes[index];
                  final isSelected = widget.selectedSize == size;
                  return GestureDetector(
                    onTap: () => widget.onSizeSelected(size),
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 44),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withAlpha(100),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        size,
                        style: TextStyle(
                          color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    String name = colorName.toLowerCase();
    if (name.contains('navy')) return const Color(0xFF000080);
    if (name.contains('white')) return Colors.white;
    if (name.contains('red')) return const Color(0xFFD32F2F);
    if (name.contains('blue')) return const Color(0xFF1976D2);
    if (name.contains('pink')) return const Color(0xFFE91E63);
    if (name.contains('yellow')) return const Color(0xFFFFEB3B);
    if (name.contains('green')) return const Color(0xFF388E3C);
    if (name.contains('khaki')) return const Color(0xFFC3B091);
    if (name.contains('charcoal')) return const Color(0xFF36454F);
    if (name.contains('black')) return Colors.black;
    if (name.contains('grey') || name.contains('gray')) return Colors.grey;
    return Colors.grey;
  }

  Color _getIconColor(Color displayColor, String name) {
    name = name.toLowerCase();
    if (displayColor == Colors.white || name.contains('cream') || name.contains('yellow')) {
      return Colors.black;
    }
    return Colors.white;
  }
}
