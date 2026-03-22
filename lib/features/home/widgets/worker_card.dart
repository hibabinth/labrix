import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/worker_model.dart';
import '../view/worker_detail_screen.dart';

class WorkerCard extends StatelessWidget {
  final WorkerModel worker;

  const WorkerCard({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
          child: const Icon(
            Icons.person,
            color: AppColors.primaryColor,
            size: 28,
          ),
        ),
        title: Text(
          worker.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimaryColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${worker.category} • ${worker.experienceYears}y exp',
              style: const TextStyle(color: AppColors.textSecondaryColor),
            ),
            const SizedBox(height: 6),
            Text(
              worker.priceRange,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondaryColor,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkerDetailScreen(worker: worker),
            ),
          );
        },
      ),
    );
  }
}
