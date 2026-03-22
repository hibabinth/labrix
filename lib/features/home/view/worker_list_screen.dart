import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/home_viewmodel.dart';
import '../widgets/worker_card.dart';

class WorkerListScreen extends StatefulWidget {
  final String categoryName;
  const WorkerListScreen({super.key, required this.categoryName});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(
        context,
        listen: false,
      ).filterWorkers('', widget.categoryName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = Provider.of<HomeViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          '${widget.categoryName} Workers',
          style: const TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
      ),
      body: homeVM.filteredWorkers.isEmpty
          ? const Center(child: Text('No workers found for this category.'))
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
