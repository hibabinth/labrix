import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/booking_viewmodel.dart';
import '../../reviews/view/create_review_screen.dart';

class UserBookingsScreen extends StatefulWidget {
  const UserBookingsScreen({super.key});

  @override
  State<UserBookingsScreen> createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends State<UserBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        Provider.of<BookingViewModel>(
          context,
          listen: false,
        ).loadUserBookings(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingVM = Provider.of<BookingViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: bookingVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : bookingVM.userBookings.isEmpty
          ? const Center(
              child: Text(
                'No bookings found.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryColor,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookingVM.userBookings.length,
              itemBuilder: (context, index) {
                final booking = bookingVM.userBookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      'Booking #${booking.id.substring(0, 6)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${booking.date?.toLocal().toString().split(' ')[0]} at ${booking.time}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${booking.status}',
                          style: TextStyle(
                            color: _getStatusColor(booking.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (booking.status.toLowerCase() == 'completed') ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 32,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CreateReviewScreen(booking: booking),
                                  ),
                                );
                              },
                              child: const Text(
                                'Leave a Review',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Detail view or chat feature
                    },
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return AppColors.successColor;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textPrimaryColor;
    }
  }
}
