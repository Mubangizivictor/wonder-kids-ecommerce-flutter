import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecom/features/presentation/providers/category_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../domain/models/category_model.dart';

class AdminCategoriesView extends StatelessWidget {
  const AdminCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final catProvider = Provider.of<CategoryProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
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
                  'Categories',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton.filled(
                  onPressed: () => catProvider.fetchCategories(),
                  icon: const Icon(LucideIcons.refreshCcw, size: 20),
                  tooltip: 'Refresh Categories',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: catProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: catProvider.categories.length,
                      itemBuilder: (context, index) {
                        final cat = catProvider.categories[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.dividerColor.withAlpha(40)),
                          ),
                          child: ListTile(
                            leading: Icon(cat.icon, color: theme.colorScheme.primary),
                            title: Text(cat.getTitle(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('ID: ${cat.id}', style: theme.textTheme.labelSmall),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.edit2, size: 20),
                                  onPressed: () => _showAddCategoryDialog(context, category: cat),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 20, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(context, cat.titleKey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, {CategoryModel? category}) {
    final controller = TextEditingController(text: category?.titleKey);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Category Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  if (category == null) {
                    await context.read<CategoryProvider>().addCategory(controller.text, LucideIcons.layoutGrid);
                  } else {
                    await context.read<CategoryProvider>().updateCategory(category.titleKey, controller.text, category.icon);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(category == null ? 'Category added' : 'Category updated')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Permission Denied: Ensure you have Admin rights in Firestore.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(category == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: const Text('This will remove the category. Products in this category will remain but may lose their grouping.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await context.read<CategoryProvider>().deleteCategory(title);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Permission Denied: Could not delete category.'),
                      backgroundColor: Colors.red,
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
