import 'package:flutter/material.dart';
import '../../../data/models/booking_model.dart';
import '../../../core/theme/app_colors.dart';
import '../widget/receipt_widget.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Digital Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ReceiptWidget(booking: booking),
            const SizedBox(height: 32),
            
            // 🛡️ Extra Support Info
            const Text(
              'Need help with this booking?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you have issues with this service, please contact our 24/7 support team with your Transaction ID.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryColor, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement PDF Export
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Download functionality coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text('Download PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Return to History', style: TextStyle(color: AppColors.textSecondaryColor)),
            ),
          ],
        ),
      ),
    );
  }
}
