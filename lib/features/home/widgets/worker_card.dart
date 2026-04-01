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
          backgroundImage: (worker.imageUrl != null && worker.imageUrl!.isNotEmpty)
              ? NetworkImage(worker.imageUrl!)
              : null,
          child: (worker.imageUrl == null || worker.imageUrl!.isEmpty)
              ? const Icon(Icons.person, color: AppColors.primaryColor, size: 28)
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                worker.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: worker.isOnline ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: worker.isOnline ? Colors.green : Colors.grey, size: 8),
                  const SizedBox(width: 4),
                  Text(
                    worker.isOnline ? 'Online' : 'Away',
                    style: TextStyle(
                      color: worker.isOnline ? Colors.green : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${worker.category} • ${worker.experienceYears}y exp',
              style: const TextStyle(color: AppColors.textSecondaryColor, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              worker.priceRange,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondaryColor,
          size: 20,
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
