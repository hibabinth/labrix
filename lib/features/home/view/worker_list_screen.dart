import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/home_viewmodel.dart';
import '../widgets/worker_card.dart';

class WorkerListScreen extends StatefulWidget {
  final String categoryName;
  final String? parentCategory;

  const WorkerListScreen({
    super.key,
    required this.categoryName,
    this.parentCategory,
  });

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVM = Provider.of<HomeViewModel>(context, listen: false);
      // If parentCategory is set, this is a subcategory filter
      if (widget.parentCategory != null) {
        homeVM.filterWorkers(
          '',
          widget.parentCategory,
          subcategory: widget.categoryName,
        );
      } else {
        homeVM.filterWorkers('', widget.categoryName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
        actions: [
          if (widget.parentCategory != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  widget.parentCategory!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryColor,
                  ),
                ),
                backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                side: BorderSide.none,
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
      body: homeVM.filteredWorkers.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('😕', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'No workers found for\n"${widget.categoryName}"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: homeVM.filteredWorkers.length,
              itemBuilder: (context, index) {
                return WorkerCard(worker: homeVM.filteredWorkers[index]);
              },
            ),
    );
  }
}
