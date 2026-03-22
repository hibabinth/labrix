import 'package:flutter/material.dart';
import '../../home/view/main_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/viewmodel/profile_viewmodel.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../data/models/worker_model.dart';

class WorkerProfileSetupScreen extends StatefulWidget {
  const WorkerProfileSetupScreen({super.key});

  @override
  State<WorkerProfileSetupScreen> createState() =>
      _WorkerProfileSetupScreenState();
}

class _WorkerProfileSetupScreenState extends State<WorkerProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _priceRangeController = TextEditingController();

  String _selectedCategory = 'Plumbing';
  final List<String> _categories = [
    'Plumbing',
    'Electrician',
    'Cleaning',
    'Welding',
    'Carpentry',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    _priceRangeController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();
    final experience = int.tryParse(_experienceController.text.trim()) ?? 0;
    final priceRange = _priceRangeController.text.trim();

    if (name.isEmpty || priceRange.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);

    final userId = authVM.currentUser?.id;
    if (userId == null) return;

    final worker = WorkerModel(
      id: userId,
      role: 'worker',
      name: name,
      phone: phone,
      location: location,
      category: _selectedCategory,
      experienceYears: experience,
      priceRange: priceRange,
      isOnline: true,
      isVerified: false,
    );

    final success = await profileVM.saveWorkerProfile(worker);
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const MainScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileVM.errorMessage ?? 'Failed to save profile'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('Worker Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CustomTextField(
              controller: _nameController,
              hintText: 'Full Name *',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              hintText: 'Phone Number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _locationController,
              hintText: 'Address / Location',
              prefixIcon: Icons.location_on,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.category,
                  color: AppColors.primaryColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _experienceController,
              hintText: 'Years of Experience',
              prefixIcon: Icons.timer,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _priceRangeController,
              hintText: 'Rate (e.g. \$20/hr) *',
              prefixIcon: Icons.attach_money,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Complete Setup',
              onPressed: _saveProfile,
              isLoading: profileVM.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
