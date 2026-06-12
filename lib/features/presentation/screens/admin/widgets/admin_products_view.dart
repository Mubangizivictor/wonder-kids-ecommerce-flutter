import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/presentation/providers/product_provider.dart';
import 'package:ecom/core/constants/category_list.dart';
import 'package:ecom/features/domain/models/product_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

import '../../../providers/category_provider.dart';

class AdminProductsView extends StatefulWidget {
  const AdminProductsView({super.key});

  @override
  State<AdminProductsView> createState() => _AdminProductsViewState();
}

class _AdminProductsViewState extends State<AdminProductsView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final theme = Theme.of(context);

    final filteredProducts = productProvider.products.where((product) {
      return product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(context),
        child: const Icon(LucideIcons.plus),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  'Inventory',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${productProvider.products.length} Items',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                ),
                IconButton.filled(
                  onPressed: () => productProvider.fetchProducts(),
                  icon: const Icon(LucideIcons.refreshCcw, size: 20),
                  tooltip: 'Refresh Products',
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final productProv = context.read<ProductProvider>();
                    
                    try {
                      // Seed products - Categories are hardcoded in CategoryList
                      await productProv.seedProducts();
                      
                      messenger.removeCurrentSnackBar();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('MVP Data (Products) seeded successfully'),
                          duration: Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Error seeding data: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  icon: const Icon(LucideIcons.databaseBackup, size: 18),
                  label: const Text('Seed MVP Data'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: productProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProducts.isEmpty 
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.packageSearch, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? 'No products in inventory' : 'No products matching "$_searchQuery"',
                              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                            ),
                            if (_searchQuery.isNotEmpty)
                              TextButton(
                                onPressed: () => setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                }),
                                child: const Text('Clear Search'),
                              ),
                          ],
                        ),
                      )
                    : _buildProductsGrid(context, filteredProducts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(BuildContext context, List<ProductModel> products) {
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).dividerColor.withAlpha(40)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imgUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.image, size: 40),
              ),
            ),
            title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.category, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)),
                Text(product.getFormattedPrice('UGX'), style: const TextStyle(fontWeight: FontWeight.w600)),
                if (product.stockStatus)
                  const Text('OUT OF STOCK', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.edit2, size: 20),
                  onPressed: () => _showProductDialog(context, product: product),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(context, product.id, product.productImages),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductDialog(BuildContext screenContext, {ProductModel? product}) {
    final titleController = TextEditingController(text: product?.title);
    final titleArController = TextEditingController(text: product?.titleAr);
    final descController = TextEditingController(text: product?.description);
    final descArController = TextEditingController(text: product?.descriptionAr);
    final priceController = TextEditingController(text: product?.price.toString());
    final discountedPriceController = TextEditingController(text: product?.discountedPrice.toString());
    final colorController = TextEditingController();
    final sizeController = TextEditingController();
    
    // Use CategoryProvider for accurate localized titles
    final categoryProvider = Provider.of<CategoryProvider>(screenContext, listen: false);
    final availableCategories = categoryProvider.categories.where((c) => c.titleKey != 'All').toList();
    final categoryTitleKeys = availableCategories.map((c) => c.titleKey).toSet().toList();
    
    // Ensure the selected category exists in the list to avoid DropdownButton assertion crash
    String selectedCategoryKey = product?.category ?? (categoryTitleKeys.isNotEmpty ? categoryTitleKeys.first : 'Clothing');
    
    // Auto-map old category name to new one if applicable
    if (selectedCategoryKey == 'Baby Essentials' && categoryTitleKeys.contains('Baby Gear')) {
      selectedCategoryKey = 'Baby Gear';
    }

    if (!categoryTitleKeys.contains(selectedCategoryKey)) {
      if (categoryTitleKeys.isNotEmpty) {
        selectedCategoryKey = categoryTitleKeys.first;
      }
    }
    
    bool isOutOfStock = product?.stockStatus ?? false;
    List<String> uploadedImages = List.from(product?.productImages ?? []);
    List<String> selectedColors = List.from(product?.productColors ?? []);
    List<String> selectedSizes = List.from(product?.productSizes ?? []);
    if (uploadedImages.isEmpty && product?.imgUrl != null && product!.imgUrl.isNotEmpty) {
      uploadedImages.add(product.imgUrl);
    }

    final ImagePicker picker = ImagePicker();

    showDialog(
      context: screenContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pickImage() async {
            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              setModalState(() => screenContext.read<ProductProvider>().setDialogLoading(true));
              try {
                String fileName = 'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
                Reference ref = FirebaseStorage.instance.ref().child(fileName);

                final Uint8List imageBytes = await image.readAsBytes();
                
                // For mobile, we can still try to compress, but for now let's use the bytes directly for compatibility
                await ref.putData(
                  imageBytes, 
                  SettableMetadata(contentType: 'image/jpeg')
                );

                String url = await ref.getDownloadURL();
                setModalState(() => uploadedImages.add(url));
              } catch (e) {
                debugPrint('Upload error: $e');
                if (screenContext.mounted) {
                  ScaffoldMessenger.of(screenContext).showSnackBar(
                    SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
                  );
                }
              } finally {
                setModalState(() => screenContext.read<ProductProvider>().setDialogLoading(false));
              }
            }
          }

          final productProvider = screenContext.watch<ProductProvider>();

          return AlertDialog(
            title: Text(product == null ? 'Add New Product' : 'Edit Product'),
            content: SizedBox(
              width: 500, // Fixed width to prevent intrinsic dimension errors with SingleChildScrollView
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title (EN)')),
                  TextField(controller: titleArController, decoration: const InputDecoration(labelText: 'Title (AR)')),
                  TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description (EN)')),
                  TextField(controller: descArController, decoration: const InputDecoration(labelText: 'Description (AR)')),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price (UGX)'), keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: discountedPriceController, decoration: const InputDecoration(labelText: 'Disc. Price'), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: categoryTitleKeys.contains(selectedCategoryKey) 
                        ? selectedCategoryKey 
                        : (categoryTitleKeys.isNotEmpty ? categoryTitleKeys.first : null),
                    items: availableCategories
                        .map((cat) => DropdownMenuItem(value: cat.titleKey, child: Text(cat.getTitle(context))))
                        .toList(),
                    onChanged: (val) => setModalState(() => selectedCategoryKey = val!),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Out of Stock'),
                    value: isOutOfStock,
                    onChanged: (val) => setModalState(() => isOutOfStock = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Product Variants', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  // Colors Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: colorController,
                        decoration: InputDecoration(
                          labelText: 'Add Available Color',
                          hintText: 'e.g. Red',
                          prefixIcon: const Icon(LucideIcons.palette, size: 18),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.green),
                            onPressed: () {
                              if (colorController.text.trim().isNotEmpty) {
                                setModalState(() {
                                  selectedColors.add(colorController.text.trim());
                                  colorController.clear();
                                });
                              }
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            setModalState(() {
                              selectedColors.add(val.trim());
                              colorController.clear();
                            });
                          }
                        },
                      ),
                      if (selectedColors.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedColors.map((c) => Chip(
                            label: Text(c),
                            onDeleted: () => setModalState(() => selectedColors.remove(c)),
                            deleteIconColor: Colors.red,
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sizes Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: sizeController,
                        decoration: InputDecoration(
                          labelText: 'Add Available Size',
                          hintText: 'e.g. XL or 2-3 Years',
                          prefixIcon: const Icon(LucideIcons.ruler, size: 18),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.blue),
                            onPressed: () {
                              if (sizeController.text.trim().isNotEmpty) {
                                setModalState(() {
                                  selectedSizes.add(sizeController.text.trim());
                                  sizeController.clear();
                                });
                              }
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            setModalState(() {
                              selectedSizes.add(val.trim());
                              sizeController.clear();
                            });
                          }
                        },
                      ),
                      if (selectedSizes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedSizes.map((s) => Chip(
                            label: Text(s),
                            onDeleted: () => setModalState(() => selectedSizes.remove(s)),
                            deleteIconColor: Colors.blue,
                            backgroundColor: Colors.blue[50],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Product Images', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...uploadedImages.map((url) => Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              right: 4,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => setModalState(() => uploadedImages.remove(url)),
                              ),
                            ),
                          ],
                        )),
                        InkWell(
                          onTap: pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Icon(LucideIcons.camera),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (productProvider.isDialogLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: productProvider.isDialogLoading ? null : () async {
                  if (uploadedImages.isEmpty) {
                    ScaffoldMessenger.of(screenContext).showSnackBar(const SnackBar(content: Text('Please add at least one image')));
                    return;
                  }
                  try {
                    final newProduct = ProductModel(
                      id: product?.id ?? '',
                      title: titleController.text,
                      titleAr: titleArController.text.isNotEmpty ? titleArController.text : null,
                      description: descController.text,
                      descriptionAr: descArController.text.isNotEmpty ? descArController.text : null,
                      price: double.tryParse(priceController.text.replaceAll(',', '')) ?? 0.0,
                      discountedPrice: double.tryParse(discountedPriceController.text.replaceAll(',', '')) ?? (double.tryParse(priceController.text.replaceAll(',', '')) ?? 0.0),
                      imgUrl: uploadedImages.first,
                      images: uploadedImages,
                      category: selectedCategoryKey,
                      isOutOfStock: isOutOfStock,
                      colors: selectedColors,
                      sizes: selectedSizes,
                    );

                    if (product == null) {
                      await screenContext.read<ProductProvider>().addProduct(newProduct);
                      // Clear search query to ensure the new product is visible
                      if (mounted) {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      }
                    } else {
                      await screenContext.read<ProductProvider>().updateProduct(newProduct);
                    }
                    if (screenContext.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(screenContext).removeCurrentSnackBar();
                      ScaffoldMessenger.of(screenContext).showSnackBar(
                        SnackBar(
                          content: Text(product == null ? 'Product added' : 'Product updated'),
                          duration: const Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('Error saving product: $e');
                    if (screenContext.mounted) {
                      ScaffoldMessenger.of(screenContext).showSnackBar(
                        const SnackBar(content: Text('Error saving product'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext screenContext, String id, List<String> images) {
    showDialog(
      context: screenContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('This action cannot be undone and will delete all associated images.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await screenContext.read<ProductProvider>().deleteProductWithImages(id, images);
                if (screenContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(screenContext).removeCurrentSnackBar();
                  ScaffoldMessenger.of(screenContext).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted'),
                      duration: Duration(milliseconds: 1500),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Error deleting product: $e');
                if (screenContext.mounted) {
                  ScaffoldMessenger.of(screenContext).removeCurrentSnackBar();
                  ScaffoldMessenger.of(screenContext).showSnackBar(
                    const SnackBar(
                      content: Text('Error deleting product.'),
                      backgroundColor: Colors.red,
                      duration: Duration(milliseconds: 2000),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
