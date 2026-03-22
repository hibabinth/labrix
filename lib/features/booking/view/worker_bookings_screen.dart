import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/booking_viewmodel.dart';

class WorkerBookingsScreen extends StatefulWidget {
  const WorkerBookingsScreen({super.key});

  @override
  State<WorkerBookingsScreen> createState() => _WorkerBookingsScreenState();
}

class _WorkerBookingsScreenState extends State<WorkerBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workerId = Supabase.instance.client.auth.currentUser?.id;
      if (workerId != null) {
        Provider.of<BookingViewModel>(
          context,
          listen: false,
        ).loadWorkerBookings(workerId);
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
          'Job Requests',
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: bookingVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : bookingVM.workerBookings.isEmpty
          ? const Center(
              child: Text(
                'No job requests yet.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryColor,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookingVM.workerBookings.length,
              itemBuilder: (context, index) {
                final booking = bookingVM.workerBookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Request',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${booking.date?.toLocal().toString().split(' ')[0]}',
                        ),
                        Text('Time: ${booking.time}'),
                        if (booking.notes != null &&
                            booking.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Notes: ${booking.notes}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status: ${booking.status}',
                              style: TextStyle(
                                color: _getStatusColor(booking.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (booking.status.toLowerCase() == 'pending')
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => bookingVM.updateStatus(
                                      booking.id,
                                      'cancelled',
                                    ),
                                    child: const Text(
                                      'Decline',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                    ),
                                    onPressed: () => bookingVM.updateStatus(
                                      booking.id,
                                      'accepted',
                                    ),
                                    child: const Text(
                                      'Accept',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            if (booking.status.toLowerCase() == 'accepted')
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.successColor,
                                ),
                                onPressed: () => bookingVM.updateStatus(
                                  booking.id,
                                  'completed',
                                ),
                                child: const Text(
                                  'Mark Complete',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
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
