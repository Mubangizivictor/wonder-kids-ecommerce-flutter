import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/category_list.dart';
import 'package:ecom/shared_widgets/category_tabs.dart';
import 'package:ecom/shared_widgets/custom_search_bar.dart';
import 'package:ecom/l10n/app_localizations.dart';
import '../product/widgets/product_card_vertical.dart';
import 'widgets/shop_app_bar.dart';
import 'widgets/filter_button.dart';
import 'widgets/shop_filter_bottom_sheet.dart';
import 'widgets/shop_sort_bottom_sheet.dart';
import 'package:ecom/shared_widgets/custom_elevated_button.dart';

import 'package:ecom/features/presentation/screens/home/widgets/product_grid.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSortIndex = 0;
  bool _isGridView = true;
  String _searchQuery = '';
  String _selectedPriceRange = 'All';

  @override
  void initState() {
    super.initState();
    final categories = CategoryList.catList;
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryList.catList;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final List<String> sortOptions = [
      l10n.featured,
      l10n.priceLowToHigh,
      l10n.priceHighToLow,
      l10n.newest,
      l10n.bestSelling,
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const ShopAppBar(),
            CustomSearchBar(
              onSearch: (query) => setState(() => _searchQuery = query),
              onFilterChanged: (range) => setState(() => _selectedPriceRange = range),
            ),
            
            // Utility Row: Sort and View Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: FilterButton(
                      label: sortOptions[_selectedSortIndex],
                      icon: LucideIcons.arrowUpDown,
                      onTap: () => _showSortBottomSheet(sortOptions),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilterButton(
                      label: _isGridView ? l10n.gridView : l10n.listView,
                      icon: _isGridView ? LucideIcons.layoutGrid : LucideIcons.list,
                      onTap: () => setState(() => _isGridView = !_isGridView),
                    ),
                  ),
                ],
              ),
            ),

            CategoryTabs(categories: categories, tabController: _tabController),
            const SizedBox(height: 4),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: categories.map((category) {
                  return ProductGrid(
                    category: category,
                    isGridView: _isGridView,
                    searchQuery: _searchQuery,
                    priceRange: _selectedPriceRange,
                    sortIndex: _selectedSortIndex,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet(List<String> sortOptions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShopSortBottomSheet(
        sortOptions: sortOptions,
        selectedSortIndex: _selectedSortIndex,
        onSortOptionSelected: (index) {
          setState(() => _selectedSortIndex = index);
        },
      ),
    );
  }
}
