import 'package:ecom/features/domain/models/category_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// This file defines the navigation categories for Wonder Kids.
// Using playful icons for a friendly kids' store look.
class CategoryList {
  static final List<CategoryModel> catList = [
    CategoryModel(
      id: 0,
      titleKey: "All",
      icon: LucideIcons.layoutGrid,
    ),
    CategoryModel(
      id: 1,
      titleKey: "Clothing",
      icon: LucideIcons.shirt,
    ),
    CategoryModel(
      id: 2,
      titleKey: "Toys & Learning",
      icon: LucideIcons.rocket,
    ),
    CategoryModel(
      id: 3,
      titleKey: "Baby Gear",
      icon: LucideIcons.baby,
    ),
    CategoryModel(
      id: 4,
      titleKey: "School & Stationery",
      icon: LucideIcons.bookOpen,
    ),
    CategoryModel(
      id: 5,
      titleKey: "Footwear",
      icon: LucideIcons.footprints,
    ),
  ];
}
