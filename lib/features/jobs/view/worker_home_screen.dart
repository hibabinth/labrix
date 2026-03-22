import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/viewmodel/profile_viewmodel.dart';
import '../viewmodel/job_vacancy_viewmodel.dart';
import 'job_detail_screen.dart'; // We will create this

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      final jobVM = Provider.of<JobVacancyViewModel>(context, listen: false);

      // Default to worker's own category
      _selectedCategory = profileVM.currentProfile?.role == 'worker'
          ? (profileVM.currentProfile?.toJson()['category'] as String?)
          : null;

      jobVM.loadOpenVacancies(category: _selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobVM = Provider.of<JobVacancyViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Job Board',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: jobVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  jobVM.loadOpenVacancies(category: _selectedCategory),
              color: AppColors.primaryColor,
              child: jobVM.openVacancies.isEmpty
                  ? const Center(
                      child: Text('No open jobs found in your category.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: jobVM.openVacancies.length,
                      itemBuilder: (context, index) {
                        final job = jobVM.openVacancies[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: InkWell(
                            onTap: () {
                              // Navigate to Job Details to apply
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JobDetailScreen(job: job),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          job.category,
                                          style: const TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '\$${job.budget.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: AppColors.successColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    job.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    job.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        job.location,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        job.dateNeeded
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
