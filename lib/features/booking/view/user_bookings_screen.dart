import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/booking_viewmodel.dart';
import '../../chat/view/chat_room_screen.dart';
import 'leave_review_dialog.dart';
import 'package:intl/intl.dart';
import 'booking_detail_screen.dart';

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
      _loadBookings();
    });
  }

  void _loadBookings() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      Provider.of<BookingViewModel>(context, listen: false).loadUserBookings(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingVM = Provider.of<BookingViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: bookingVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : bookingVM.userBookings.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async => _loadBookings(),
                  color: AppColors.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                    itemCount: bookingVM.userBookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookingVM.userBookings[index];
                      return _buildBookingCard(booking, bookingVM);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Book a professional service and\nit will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondaryColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(booking, BookingViewModel vm) {
    final dateStr = booking.date != null
        ? DateFormat('EEE, MMM dd, yyyy').format(booking.date!)
        : 'No date';
    final isPending = booking.status.toLowerCase() == 'pending';
    final isCompleted = booking.status.toLowerCase() == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon/Image
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    image: booking.profile?.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(booking.profile!.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: booking.profile?.imageUrl == null
                      ? const Icon(Icons.engineering_outlined,
                          color: AppColors.primaryColor)
                      : null,
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.profile?.name ?? 'Professional Service',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Booking #${booking.id.substring(0, 6).toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$dateStr • ${booking.time}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status & Price Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        booking.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(booking.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${booking.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (booking.notes != null && booking.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.notes!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ),
            ),
          // Actions
          if (booking.status.toLowerCase() != 'cancelled')
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  // Always show Chat if not cancelled
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(booking: booking),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline,
                          color: AppColors.primaryColor, size: 18),
                      label: const Text('Chat',
                          style: TextStyle(color: AppColors.primaryColor)),
                    ),
                  ),
                  if (isPending) ...[
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _confirmCancel(context, booking, vm),
                        icon: const Icon(Icons.close,
                            color: Colors.redAccent, size: 18),
                        label: const Text('Cancel Request',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                  ],
                  if (isCompleted) ...[
                    Expanded(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingDetailScreen(booking: booking),
                            ),
                          );
                        },
                        icon: const Icon(Icons.receipt_long_outlined,
                            color: Colors.blueAccent, size: 18),
                        label: const Text('Invoice',
                            style: TextStyle(color: Colors.blueAccent)),
                      ),
                    ),
                    if (isCompleted && !booking.isReviewed) ...[
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () async {
                            final result = await showDialog(
                              context: context,
                              builder: (_) => LeaveReviewDialog(
                                bookingId: booking.id,
                                workerId: booking.workerId,
                                workerName: booking.profile?.name ?? 'Professional',
                              ),
                            );
                            if (result == true) {
                              _loadBookings(); // Refresh to hide rate button
                            }
                          },
                          icon: const Icon(Icons.star_outline,
                              color: AppColors.primaryColor, size: 18),
                          label: const Text('Rate',
                              style: TextStyle(color: AppColors.primaryColor)),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _confirmCancel(context, booking, vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Booking?'),
        content: const Text(
            'Are you sure you want to cancel this booking request? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep it'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final userId = Supabase.instance.client.auth.currentUser?.id;
              await vm.updateStatus(booking.id, 'cancelled', userId: userId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.white)),
          ),
        ],
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
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
