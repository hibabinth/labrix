import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/worker_model.dart';
import '../viewmodel/profile_viewmodel.dart';

class AvailabilitySettingsScreen extends StatefulWidget {
  const AvailabilitySettingsScreen({super.key});

  @override
  State<AvailabilitySettingsScreen> createState() => _AvailabilitySettingsScreenState();
}

class _AvailabilitySettingsScreenState extends State<AvailabilitySettingsScreen> {
  String? _startTime;
  String? _endTime;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileViewModel>(context, listen: false).currentProfile;
    if (profile is WorkerModel) {
      _startTime = profile.workingStart;
      _endTime = profile.workingEnd;
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final formattedTime = picked.format(context);
        if (isStart) {
          _startTime = formattedTime;
        } else {
          _endTime = formattedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    final worker = profileVM.currentProfile as WorkerModel;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Working Hours', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set your professional hours',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryColor),
            ),
            const SizedBox(height: 8),
            const Text(
              'Customers will see these hours on your profile to know when you are available for bookings.',
              style: TextStyle(color: AppColors.textSecondaryColor, fontSize: 14),
            ),
            const SizedBox(height: 40),
            
            _buildTimeTile(
              context,
              label: 'SHIFT START',
              time: _startTime ?? '08:00 AM',
              icon: Icons.wb_sunny_outlined,
              onTap: () => _selectTime(context, true),
            ),
            
            const SizedBox(height: 20),
            
            _buildTimeTile(
              context,
              label: 'SHIFT END',
              time: _endTime ?? '05:00 PM',
              icon: Icons.nightlight_round_outlined,
              onTap: () => _selectTime(context, false),
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: profileVM.isLoading 
                  ? null 
                  : () async {
                      final updatedWorker = worker.copyWith(
                        workingStart: _startTime,
                        workingEnd: _endTime,
                      );
                      final success = await profileVM.saveWorkerProfile(updatedWorker);
                      if (success && mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Working hours updated!')),
                        );
                      }
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: profileVM.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('SAVE SCHEDULE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile(BuildContext context, {
    required String label, 
    required String time, 
    required IconData icon, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primaryColor),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.textSecondaryColor.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryColor)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
