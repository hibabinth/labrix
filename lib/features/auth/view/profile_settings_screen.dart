import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'splash_screen.dart';
import '../../../shared/widgets/custom_button.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final profileVM = Provider.of<ProfileViewModel>(context);
    final profile = profileVM.currentProfile;
    final user = authVM.currentUser;

    if (profile == null || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Profile Settings',
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.errorColor),
            onPressed: () async {
              await authVM.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person,
                size: 50,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: profile.role == 'worker'
                    ? Colors.orange.withValues(alpha: 0.2)
                    : Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                profile.role.toUpperCase(),
                style: TextStyle(
                  color: profile.role == 'worker'
                      ? Colors.orange.shade800
                      : Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildInfoTile(Icons.email, 'Email', user.email ?? 'No email'),
            const Divider(),
            _buildInfoTile(Icons.phone, 'Phone', profile.phone),
            const Divider(),
            _buildInfoTile(Icons.location_on, 'Location', profile.location),
            const SizedBox(height: 48),
            CustomButton(
              text: 'Log Out',
              onPressed: () async {
                await authVM.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondaryColor,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: AppColors.textPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
