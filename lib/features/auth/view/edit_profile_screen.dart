import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/models/worker_model.dart';

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
  late TextEditingController _headlineController;
  late TextEditingController _interestsController;
  
  File? _selectedImage;
  File? _selectedCover;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _dobController = TextEditingController(text: widget.profile.dob ?? '');
    _locationController = TextEditingController(text: widget.profile.location);
    _aboutMeController = TextEditingController(text: widget.profile.aboutMe ?? '');
    _headlineController = TextEditingController(text: widget.profile.headline ?? '');
    _interestsController = TextEditingController(text: widget.profile.interests.join('; '));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    _aboutMeController.dispose();
    _headlineController.dispose();
    _interestsController.dispose();
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

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedCover = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isUploading = true);
    
    try {
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);

      String? imageUrl = widget.profile.imageUrl;
      String? coverImageUrl = widget.profile.coverImageUrl;
      
      // Upload image if a new one is selected
      if (_selectedImage != null) {
        imageUrl = await profileVM.uploadAvatar(widget.profile.id, _selectedImage!);
      }

      if (_selectedCover != null) {
        coverImageUrl = await profileVM.uploadCoverImage(widget.profile.id, _selectedCover!);
      }

      final interestsList = _interestsController.text
          .split(';')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      ProfileModel updatedProfile;
      
      if (widget.profile is WorkerModel) {
        final worker = widget.profile as WorkerModel;
        updatedProfile = WorkerModel(
          id: worker.id,
          role: worker.role,
          name: _nameController.text.trim(),
          phone: worker.phone,
          location: _locationController.text.trim(),
          imageUrl: imageUrl,
          followers: worker.followers,
          following: worker.following,
          aboutMe: _aboutMeController.text.trim().isNotEmpty ? _aboutMeController.text.trim() : null,
          interests: interestsList,
          category: worker.category,
          experienceYears: worker.experienceYears,
          priceRange: worker.priceRange,
          isOnline: worker.isOnline,
          isVerified: worker.isVerified,
          skills: worker.skills,
          education: worker.education,
          portfolioUrls: worker.portfolioUrls,
          rating: worker.rating,
          ratingCount: worker.ratingCount,
          coverImageUrl: coverImageUrl,
          headline: _headlineController.text.trim().isNotEmpty ? _headlineController.text.trim() : null,
          dob: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
        );
      } else {
        updatedProfile = ProfileModel(
          id: widget.profile.id,
          role: widget.profile.role,
          name: _nameController.text.trim(),
          phone: widget.profile.phone,
          location: _locationController.text.trim(),
          imageUrl: imageUrl,
          followers: widget.profile.followers,
          following: widget.profile.following,
          aboutMe: _aboutMeController.text.trim().isNotEmpty ? _aboutMeController.text.trim() : null,
          interests: interestsList,
          companyName: widget.profile.companyName,
          details: widget.profile.details,
          coverImageUrl: coverImageUrl,
          headline: _headlineController.text.trim().isNotEmpty ? _headlineController.text.trim() : null,
          dob: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
        );
      }

      final success = await profileVM.saveUserProfile(updatedProfile);

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
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            colorScheme: const ColorScheme.light(primary: AppColors.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _dobController.text = formattedDate;
      });
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
              // Cover and Avatar Section
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Cover Photo
                    Align(
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: _pickCoverImage,
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                            image: _selectedCover != null
                                ? DecorationImage(image: FileImage(_selectedCover!), fit: BoxFit.cover)
                                : (widget.profile.coverImageUrl != null
                                    ? DecorationImage(image: NetworkImage(widget.profile.coverImageUrl!), fit: BoxFit.cover)
                                    : null),
                          ),
                          child: (_selectedCover == null && widget.profile.coverImageUrl == null)
                              ? const Center(child: Icon(Icons.add_a_photo, color: Colors.grey, size: 40))
                              : null,
                        ),
                      ),
                    ),
                    // Avatar Photo
                    Positioned(
                      bottom: 0,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!) as ImageProvider
                                  : (widget.profile.imageUrl != null
                                      ? NetworkImage(widget.profile.imageUrl!)
                                      : null),
                              child: (_selectedImage == null && widget.profile.imageUrl == null)
                                  ? const Icon(Icons.person, size: 40, color: AppColors.primaryColor)
                                  : null,
                            ),
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
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form Fields
              _buildTextField('Full Name', _nameController, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField('Headline', _headlineController, Icons.text_fields),
              const SizedBox(height: 16),
              _buildTextField(
                'Date of Birth', 
                _dobController, 
                Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              _buildTextField('Location', _locationController, Icons.location_on_outlined),
              const SizedBox(height: 16),
              _buildTextField('Interested Event (e.g. Design; Art)', _interestsController, Icons.local_activity_outlined),
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool readOnly = false, int maxLines = 1, VoidCallback? onTap}) {
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
          onTap: onTap,
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
