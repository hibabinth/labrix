import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../data/models/job_vacancy_model.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/job_vacancy_viewmodel.dart';
import 'package:uuid/uuid.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = 'Plumbing';
  DateTime? _selectedDate;

  final List<String> _categories = [
    'Plumbing',
    'Cleaning',
    'Electrical',
    'Painting',
    'Moving',
    'Carpentry',
  ];

  void _submitJob() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _budgetController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final jobVM = Provider.of<JobVacancyViewModel>(context, listen: false);

    final userId = authVM.currentUser!.id;
    final budget = double.tryParse(_budgetController.text) ?? 0.0;

    final newJob = JobVacancyModel(
      id: const Uuid().v4(),
      userId: userId,
      title: _titleController.text,
      description: _descController.text,
      category: _selectedCategory,
      location: _locationController.text,
      budget: budget,
      dateNeeded: _selectedDate!,
      status: 'open',
      createdAt: DateTime.now(),
    );

    final success = await jobVM.postJobVacancy(newJob);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Job posted successfully!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post job. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post a Job',
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _titleController,
              hintText: 'Job Title (e.g. Broken Pipe Repair)',
              prefixIcon: Icons.title,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.category,
                  color: AppColors.primaryColor,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              // Description
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe the work needed...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _locationController,
              hintText: 'Location / Address',
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _budgetController,
              hintText: 'Budget (\$)',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.primaryColor,
              ),
              title: Text(
                _selectedDate == null
                    ? 'Select Date Needed'
                    : _selectedDate!.toLocal().toString().split(' ')[0],
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            const SizedBox(height: 32),
            CustomButton(text: 'Post Job', onPressed: _submitJob),
          ],
        ),
      ),
    );
  }
}
