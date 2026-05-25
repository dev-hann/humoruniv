import 'package:flutter/material.dart';

import 'package:humoruniv/core/themes/app_spacing.dart';

class FilterBar<T> extends StatelessWidget {
  const FilterBar({
    required this.options,
    required this.onChanged,
    super.key,
    this.selectedValue,
  });
  final List<FilterOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.edgeH8V4,
      child: Row(
        children: options.map((option) {
          final isSelected = option.value == selectedValue;
          return Padding(
            padding: AppSpacing.edgeOnlyBottom4,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: ChoiceChip(
                label: Text(option.label),
                selected: isSelected,
                onSelected: (_) => onChanged(option.value),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FilterOption<T> {
  const FilterOption({required this.value, required this.label});
  final T value;
  final String label;
}
