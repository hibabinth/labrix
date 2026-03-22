import 'package:flutter/material.dart';
import '../../home/view/main_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/viewmodel/profile_viewmodel.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../data/models/profile_model.dart';

class UserProfileSetupScreen extends StatefulWidget {
  const UserProfileSetupScreen({super.key});

  @override
  State<UserProfileSetupScreen> createState() => _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState extends State<UserProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _companyController = TextEditingController();
  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _companyController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final location = _locationController.text.trim();
    final companyName = _companyController.text.trim();
    final details = _detailsController.text.trim();

    if (name.isEmpty || phone.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);

    final userId = authVM.currentUser?.id;
    if (userId == null) return;

    final profile = ProfileModel(
      id: userId,
      role: 'user',
      name: name,
      phone: phone,
      location: location,
      companyName: companyName.isEmpty ? null : companyName,
      details: details.isEmpty ? null : details,
    );

    final success = await profileVM.saveUserProfile(profile);
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
      appBar: AppBar(title: const Text('Setup Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CustomTextField(
              controller: _nameController,
              hintText: 'Full Name',
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
            CustomTextField(
              controller: _companyController,
              hintText: 'Company Name (Optional)',
              prefixIcon: Icons.business,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _detailsController,
              hintText: 'Details / Description (Optional)',
              prefixIcon: Icons.description,
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
