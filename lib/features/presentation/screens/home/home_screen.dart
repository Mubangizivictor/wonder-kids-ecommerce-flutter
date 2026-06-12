import 'package:flutter/material.dart';
import '../../../../core/constants/category_list.dart'; // Import our defined categories
import 'package:ecom/shared_widgets/category_tabs.dart'; // The tab UI component
import 'package:ecom/shared_widgets/custom_search_bar.dart'; // Search bar component
import 'widgets/home_appbar.dart'; // Top bar with logo/profile
import 'widgets/promo_banner.dart'; // Visual marketing banner
import 'widgets/product_grid.dart'; // The main product display area

// HomeScreen is a StatefulWidget because it needs to manage the TabController's state
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// SingleTickerProviderStateMixin is required for the TabController to handle animations
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // Controller to sync the tabs and the view
  String _searchQuery = '';
  String _selectedPriceRange = 'All';

  @override
  void initState() {
    super.initState();
    // 1. Fetch the categories we defined in our constants
    final categories = CategoryList.catList;
    
    // 2. Initialize the controller with the exact number of categories
    // 'vsync: this' ties the animation timer to this widget's lifecycle
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    // 3. IMPORTANT: Always dispose of controllers to save memory
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We fetch categories here again to build the UI elements
    final categories = CategoryList.catList;

    return Scaffold(
      // SafeArea prevents UI from being covered by the notch or status bar
      body: SafeArea(
        child: Column(
          children: [
            // Standardized Boutique App Bar
            const HomeAppbar(),

            // Custom Search Bar for product discovery
            CustomSearchBar(
              onSearch: (query) => setState(() => _searchQuery = query),
              onFilterChanged: (range) => setState(() => _selectedPriceRange = range),
            ),

            // Promotional Banner for highlighting sales/new arrivals
            const PromoBanner(),

            const SizedBox(height: 4), // Small spacing
            
            // 4. Tab Header: Shows the scrollable icons and titles
            CategoryTabs(categories: categories, tabController: _tabController),
            
            const SizedBox(height: 4),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: categories.map((category) {
                  // For every category in our list, we create a ProductGrid
                  // We pass the 'category' object so the grid knows what to filter
                  return ProductGrid(
                    category: category,
                    searchQuery: _searchQuery,
                    priceRange: _selectedPriceRange,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
