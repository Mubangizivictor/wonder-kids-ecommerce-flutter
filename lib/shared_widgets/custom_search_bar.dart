import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:ecom/l10n/app_localizations.dart';

/// A premium search bar with a filter modal and debounced search.
/// Design: Luxury minimalist with adaptive theme support.
class CustomSearchBar extends StatefulWidget {
  final Function(String)? onSearch;
  final Function(String)? onFilterChanged;
  final String? initialValue;

  const CustomSearchBar({
    super.key,
    this.onSearch,
    this.onFilterChanged,
    this.initialValue,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  Timer? _debounce;
  String _selectedPriceRange = 'All';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch?.call(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: EdgeInsets.zero,
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: isDark ? Border.all(color: theme.colorScheme.primary.withAlpha(20)) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(120) : Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Icon(
            LucideIcons.search,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              onSubmitted: (value) {
                _debounce?.cancel();
                widget.onSearch?.call(value);
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchProducts,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : theme.colorScheme.onSurface.withAlpha(100),
                  fontSize: 14,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.circleX, size: 16),
                        onPressed: () {
                          _controller.clear();
                          widget.onSearch?.call('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: false,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? theme.colorScheme.onSurface : null,
              ),
            ),
          ),
          // Filter Button
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => _buildFilterSheet(context, theme),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsetsDirectional.only(end: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(isDark ? 30 : 10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.slidersHorizontal,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildFilterSheet(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: isDark ? Border.all(color: theme.colorScheme.primary.withAlpha(20), width: 0.5) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Options',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? theme.colorScheme.onSurface : null,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setSheetState(() => _selectedPriceRange = 'All');
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Range',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? theme.colorScheme.onSurface : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        'All',
                        'Under 50k',
                        '50k - 150k',
                        '150k - 300k',
                        'Above 300k'
                      ].map((range) {
                        final isSelected = _selectedPriceRange == range;
                        return ChoiceChip(
                          label: Text(range),
                          selected: isSelected,
                          onSelected: (selected) {
                            setSheetState(() => _selectedPriceRange = range);
                          },
                          backgroundColor: isDark ? Colors.white.withAlpha(10) : theme.colorScheme.surface,
                          selectedColor: theme.colorScheme.primary.withAlpha(isDark ? 40 : 20),
                          labelStyle: TextStyle(
                            color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.white60 : Colors.black54),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withAlpha(50),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFilterChanged?.call(_selectedPriceRange);
                      Navigator.pop(context);
                    },
                    child: const Text('APPLY FILTERS'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }
}
