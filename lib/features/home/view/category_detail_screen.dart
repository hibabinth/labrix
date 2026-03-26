import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../viewmodel/home_viewmodel.dart';
import 'worker_list_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 72),
                  ),
                ),
              ),
            ),
          ),

          // Subcategory grid
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.subcategories.length} specialisations available',
                    style: const TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: category.subcategories.length + 1, // +1 for "All"
                    itemBuilder: (context, index) {
                      final isAll = index == 0;
                      final label = isAll ? 'All ${category.name}' : category.subcategories[index - 1];

                      return _SubcategoryCard(
                        label: label,
                        emoji: isAll ? category.emoji : null,
                        onTap: () {
                          final homeVM = Provider.of<HomeViewModel>(context, listen: false);
                          homeVM.filterWorkers(
                            '',
                            isAll ? category.name : null,
                            subcategory: isAll ? null : label,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkerListScreen(
                                categoryName: isAll ? category.name : label,
                                parentCategory: category.name,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubcategoryCard extends StatelessWidget {
  final String label;
  final String? emoji;
  final VoidCallback onTap;

  const _SubcategoryCard({
    required this.label,
    this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
              ] else ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
