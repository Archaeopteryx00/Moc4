import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

class CategoryRow extends StatelessWidget {
  final String selectedCategoryId;
  final ValueChanged<String> onSelected;

  const CategoryRow({
    super.key,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44, // Slightly taller for better touch target and breathing room
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: CategoryConstants.categories.length,
        itemBuilder: (context, index) {
          final category = CategoryConstants.categories[index];
          final isSelected = selectedCategoryId == category.id;
          
          String displayName = category.name;
          if (category.id == 'all') displayName = 'All Vibes';
          if (category.id == 'quiet') displayName = 'Quiet Study';
          if (category.id == 'coffee') displayName = 'Coffee Run';
          if (category.id == 'artisan') displayName = 'Hidden Gems';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(category.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.capsule),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.borderSubtle,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconData(category.icon),
                      size: 14,
                      color: isSelected ? Colors.white : AppTheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isSelected ? Colors.white : AppTheme.onSurface,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'all_inclusive':
        return Icons.all_inclusive_outlined;
      case 'volume_off':
        return Icons.volume_off_outlined;
      case 'coffee':
        return Icons.coffee_outlined;
      case 'nights_stay':
        return Icons.nights_stay_outlined;
      case 'auto_awesome':
        return Icons.auto_awesome_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
