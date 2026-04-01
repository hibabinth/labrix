import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../home/view/main_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/viewmodel/profile_viewmodel.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/models/category_model.dart';

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

  String _selectedCategory = WorkerCategory.all.first.name;

  File? _idFile;
  File? _certFile;

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

    String? idUrl;
    String? certUrl;

    if (_idFile != null) {
      idUrl = await profileVM.uploadIDDocument(userId, _idFile!);
    }
    if (_certFile != null) {
      certUrl = await profileVM.uploadCertDocument(userId, _certFile!);
    }

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
      idDocumentUrl: idUrl,
      certDocumentUrl: certUrl,
    );

    final success = await profileVM.saveWorkerProfile(worker);
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
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
              value: _selectedCategory,
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
              items: WorkerCategory.all
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.name,
                      child: Row(
                        children: [
                          Text(c.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Text(c.name),
                        ],
                      ),
                    ),
                  )
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
              hintText: 'Rate (e.g. ₹500/hr) *',
              prefixIcon: Icons.attach_money,
            ),
            const SizedBox(height: 24),
            _buildUploadSection(
              title: 'Identity Document (ID Card/Aadhar/PAN)',
              file: _idFile,
              onTap: () => _pickFile(true),
            ),
            const SizedBox(height: 16),
            _buildUploadSection(
              title: 'Professional Certificate (Optional)',
              file: _certFile,
              onTap: () => _pickFile(false),
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

  Widget _buildUploadSection({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  file != null ? Icons.check_circle : Icons.upload_file,
                  color: file != null ? Colors.green : AppColors.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    file != null ? file.path.split('/').last : 'Click to upload',
                    style: TextStyle(
                      color: file != null ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile(bool isID) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );
    if (result != null) {
      setState(() {
        if (isID) {
          _idFile = File(result.files.single.path!);
        } else {
          _certFile = File(result.files.single.path!);
        }
      });
    }
  }
}
