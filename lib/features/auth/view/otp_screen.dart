import 'package:flutter/material.dart';
import '../../home/view/main_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/widgets/custom_button.dart';
import '../viewmodel/auth_viewmodel.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.sendPhoneOTP(phone);
    if (!mounted) return;

    if (success) {
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP sent successfully!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage ?? 'Failed to send OTP'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _verifyOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter OTP')));
      return;
    }

    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.verifyPhoneOTP(phone, otp);
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
          content: Text(authVM.errorMessage ?? 'Failed to verify OTP'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Phone Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.chat, size: 80, color: AppColors.primaryColor),
            const SizedBox(height: 24),
            Text(
              _otpSent ? 'Enter OTP' : 'Enter your phone number',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _otpSent
                  ? 'An OTP was sent to ${_phoneController.text}'
                  : 'We will send you an OTP to login',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _phoneController,
              hintText: 'Phone Number (e.g. +1234567890)',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            if (_otpSent) ...[
              const SizedBox(height: 16),
              CustomTextField(
                controller: _otpController,
                hintText: '6-digit OTP',
                prefixIcon: Icons.password,
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 24),
            CustomButton(
              text: _otpSent ? 'Verify OTP' : 'Send OTP',
              onPressed: _otpSent ? _verifyOtp : _sendOtp,
              isLoading: authVM.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
