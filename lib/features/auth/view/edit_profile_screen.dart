import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../../../data/models/profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _locationController;
  late TextEditingController _aboutMeController;
  
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _dobController = TextEditingController(text: '18 February, 2001'); // Mock DOB
    _locationController = TextEditingController(text: widget.profile.location);
    _aboutMeController = TextEditingController(text: widget.profile.aboutMe ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isUploading = true);
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);

    String? imageUrl = widget.profile.imageUrl;
    
    // Upload image if a new one is selected
    if (_selectedImage != null) {
      // The ProfileViewModel doesn't directly expose uploadAvatar, so we might need to 
      // either update the viewmodel or use a generic approach.
      // Wait, let's assume we call profileVM to save it. 
      // Oh, we haven't added uploadAvatar to ProfileViewModel yet.
      // We will add it next. Let's call it via profileVM.uploadAvatar
      imageUrl = await profileVM.uploadAvatar(widget.profile.id, _selectedImage!);
    }

    final updatedProfile = ProfileModel(
      id: widget.profile.id,
      role: widget.profile.role,
      name: _nameController.text.trim(),
      phone: widget.profile.phone,
      location: _locationController.text.trim(),
      imageUrl: imageUrl,
      followers: widget.profile.followers,
      following: widget.profile.following,
      aboutMe: _aboutMeController.text.trim().isNotEmpty ? _aboutMeController.text.trim() : null,
      interests: widget.profile.interests,
      companyName: widget.profile.companyName,
      details: widget.profile.details,
    );

    final success = await profileVM.saveUserProfile(updatedProfile);
    setState(() => _isUploading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile Updated Successfully!')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(profileVM.errorMessage ?? 'Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.textPrimaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!) as ImageProvider
                          : (widget.profile.imageUrl != null 
                              ? NetworkImage(widget.profile.imageUrl!) 
                              : null),
                      child: (_selectedImage == null && widget.profile.imageUrl == null)
                          ? const Icon(Icons.person, size: 50, color: AppColors.primaryColor)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              _buildTextField('Full Name', _nameController, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField('Date of Birth', _dobController, Icons.calendar_today_outlined, readOnly: true),
              const SizedBox(height: 16),
              _buildTextField('Location', _locationController, Icons.location_on_outlined),
              const SizedBox(height: 16),
              _buildTextField('Interested Event', TextEditingController(text: 'Design; Art; Sports; Food'), Icons.local_activity_outlined, readOnly: true),
              const SizedBox(height: 16),
              _buildTextField('About Me', _aboutMeController, Icons.info_outline, maxLines: 4),

              const SizedBox(height: 48),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimaryColor, // Black button from mock
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isUploading ? null : _saveChanges,
                  child: _isUploading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool readOnly = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimaryColor, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: label,
            suffixIcon: Icon(icon, color: AppColors.textSecondaryColor, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}
