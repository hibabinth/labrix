import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryTile extends StatelessWidget {
  final String categoryName;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.categoryName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.handyman,
              color: isSelected ? Colors.white : AppColors.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              categoryName,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
