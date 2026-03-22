import 'package:flutter/material.dart';
import '../../home/view/main_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';
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

      if (profileViewModel.currentProfile == null) {
        // No profile exists, go to Role Selection
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      } else {
        // Profile exists, go to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const MainScreen(),
          ), // TODO: Replace with Home
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
