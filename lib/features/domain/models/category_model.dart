import 'package:ecom/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

class CategoryModel {
  final int id;
  final String titleKey;
  final IconData icon;
  CategoryModel({required this.id, required this.titleKey, required this.icon});

  String getTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (titleKey) {
      case 'All': return l10n.all;
      case 'Clothing': return l10n.clothing;
      case 'Toys & Learning': return l10n.toysAndLearning;
      case 'Baby Gear': return l10n.babyGear;
      case 'School & Stationery': return l10n.schoolAndStationery;
      case 'Footwear': return l10n.footwear;
      default: return titleKey;
    }
  }
}
