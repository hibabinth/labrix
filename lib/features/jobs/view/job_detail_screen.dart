import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/job_vacancy_model.dart';
import '../../../data/models/job_application_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/job_vacancy_viewmodel.dart';

class JobDetailScreen extends StatefulWidget {
  final JobVacancyModel job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _coverLetterController = TextEditingController();
  final _priceController = TextEditingController();

  void _applyToJob() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildApplicationSheet(),
    );
  }

  Widget _buildApplicationSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Submit Application',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Proposed Price (\$)',
              filled: true,
              fillColor: AppColors.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _coverLetterController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Cover Letter / Message to Hirer',
              filled: true,
              fillColor: AppColors.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Send Application',
            onPressed: () async {
              if (_priceController.text.isEmpty ||
                  _coverLetterController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              final price = double.tryParse(_priceController.text) ?? 0.0;
              final authVM = Provider.of<AuthViewModel>(context, listen: false);
              final jobVM = Provider.of<JobVacancyViewModel>(
                context,
                listen: false,
              );

              final app = JobApplicationModel(
                id: const Uuid().v4(),
                jobVacancyId: widget.job.id,
                workerId: authVM.currentUser!.id,
                coverLetter: _coverLetterController.text,
                proposedPrice: price,
                status: 'pending',
                createdAt: DateTime.now(),
              );

              final success = await jobVM.applyToJob(app);
              if (!mounted) return;
              Navigator.pop(context); // close sheet
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application sent successfully!'),
                  ),
                );
                Navigator.pop(context); // leave job details
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Failed to apply. You may have already applied.',
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Job Details',
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.job.category,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.job.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.attach_money, color: AppColors.successColor),
                const SizedBox(width: 8),
                Text(
                  'Budget: \$${widget.job.budget}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Needed By: ${widget.job.dateNeeded.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Location: ${widget.job.location}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Job Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.job.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(text: 'Apply Now', onPressed: _applyToJob),
          ],
        ),
      ),
    );
  }
}
