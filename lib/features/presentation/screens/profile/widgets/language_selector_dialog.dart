import 'package:ecom/core/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale;

    final languages = [
      {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
      {'name': 'Arabic', 'code': 'ar', 'flag': '🇸🇦'},
    ];

    return AlertDialog(
      title: const Text('Select Language'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: languages.map((lang) {
          final isSelected = currentLocale.languageCode == lang['code'];
          return ListTile(
            leading: Text(
              lang['flag']!,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              lang['name']!,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? Icon(LucideIcons.checkCircle, color: Theme.of(context).primaryColor)
                : null,
            onTap: () {
              localeProvider.setLocale(Locale(lang['code']!));
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
