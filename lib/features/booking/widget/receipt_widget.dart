import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/booking_model.dart';
import '../../../core/theme/app_colors.dart';

class ReceiptWidget extends StatelessWidget {
  final BookingModel booking;

  const ReceiptWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateStr = booking.date != null
        ? DateFormat('MMMM dd, yyyy').format(booking.date!)
        : 'Unknown Date';
    final timeStr = booking.time ?? 'Unknown Time';
    final workerName = booking.profile?.name ?? 'Professional';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🏆 Header
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Payment Receipt',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          Text(
            'Transaction ID: #${booking.id.substring(0, 8).toUpperCase()}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          
          // 📋 Details Table
          _buildRow('Service For', workerName),
          const SizedBox(height: 12),
          _buildRow('Date', dateStr),
          const SizedBox(height: 12),
          _buildRow('Time', timeStr),
          const SizedBox(height: 12),
          _buildRow('Status', booking.status.toUpperCase(), isStatus: true),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          ),
          
          // 💰 Pricing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              Text(
                '\$${booking.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // 🏁 Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.blueGrey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This is a digital receipt for your service completion. Keep this for your records.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isStatus ? Colors.green : AppColors.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}
