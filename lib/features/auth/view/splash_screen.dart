import 'package:flutter/material.dart';
import '../../home/view/main_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';
import '../../admin/view/admin_dashboard_screen.dart';
import '../../admin/view/super_admin_dashboard_screen.dart';
import '../../../data/models/profile_model.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;

    if (user != null) {
      // User is authenticated, now check if they have a profile setup
      final profileViewModel = Provider.of<ProfileViewModel>(
        context,
        listen: false,
      );
      await profileViewModel.loadProfile(user.id);
      if (!mounted) return;

      final profile = profileViewModel.currentProfile;
      
      // 🔍 SPLASH DIAGNOSTICS
      print('DEBUG [SPLASH]: Found User with ID: ${user.id}');
      if (profile == null) {
        print('DEBUG [SPLASH]: Profile is NULL for this ID');
      } else {
        print('DEBUG [SPLASH]: Profile Role is: ${profile.role}');
      }

      if (profile == null) {
        // No profile exists, go to Role Selection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      } else if (profile.role == ProfileModel.roleSuperAdmin) {
        // Direct to Super Admin Panel
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuperAdminDashboardScreen()),
        );
      } else if (profile.role == ProfileModel.roleAdmin) {
        // Direct to Admin Panel
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
      } else {
        // Standard User/Worker flow
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    } else {
      // User is not authenticated, go to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handshake, size: 80, color: AppColors.primaryColor),
            SizedBox(height: 16),
            Text(
              'Labrix',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.secondaryColor),
          ],
        ),
      ),
    );
  }
}
