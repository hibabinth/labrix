import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/booking_viewmodel.dart';
import '../../chat/view/chat_room_screen.dart';
import 'package:intl/intl.dart';
import '../../../data/models/booking_model.dart';

class WorkerBookingsScreen extends StatefulWidget {
  const WorkerBookingsScreen({super.key});

  @override
  State<WorkerBookingsScreen> createState() => _WorkerBookingsScreenState();
}

class _WorkerBookingsScreenState extends State<WorkerBookingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  void _loadBookings() {
    final workerId = Supabase.instance.client.auth.currentUser?.id;
    if (workerId != null) {
      Provider.of<BookingViewModel>(context, listen: false)
          .loadWorkerBookings(workerId)
          .then((_) => _listController.forward());
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingVM = Provider.of<BookingViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Job Requests',
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
          : bookingVM.workerBookings.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async => _loadBookings(),
                  color: AppColors.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildEarningsHeader(bookingVM.workerBookings);
                      }
                      final booking = bookingVM.workerBookings[index - 1];
                      final animation = CurvedAnimation(
                        parent: _listController,
                        curve: Interval(
                          (1 / bookingVM.workerBookings.length) * index,
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      );
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: _buildWorkerBookingCard(booking, bookingVM),
                        ),
                      );
                    },
                    itemCount: bookingVM.workerBookings.length + 1,
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text(
            'No Job Requests',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'New requests from customers will\nappear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondaryColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsHeader(List<BookingModel> bookings) {
    double totalEarnings = 0;
    int completedCount = 0;

    for (var b in bookings) {
      if (b.status.toLowerCase() == 'completed') {
        totalEarnings += b.totalPrice;
        completedCount++;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondaryColor, Color(0xFFE67E22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Earnings',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount Jobs',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalEarnings.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Keep up the great work!',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerBookingCard(booking, BookingViewModel vm) {
    final dateStr = booking.date != null
        ? DateFormat('EEE, MMM dd, yyyy').format(booking.date!)
        : 'No date';
    final isPending = booking.status.toLowerCase() == 'pending';
    final isAccepted = booking.status.toLowerCase() == 'accepted';

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
                      ? const Icon(Icons.person_outline,
                          color: AppColors.primaryColor)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.profile?.name ?? 'Service Request',
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
                // Status & Earnings Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            _getStatusColor(booking.status).withValues(alpha: 0.1),
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
          // Additional Info Row (Location / Price Placeholder if existed)
          if (booking.notes != null && booking.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Notes:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimaryColor,
                        height: 1.4,
                      ),
                    ),
                  ],
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
                  // Always show Chat for worker if not cancelled
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
                      child: TextButton(
                        onPressed: () => _updateStatus(
                            context, vm, booking.id, 'cancelled'),
                        child: const Text('Decline',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _updateStatus(
                            context, vm, booking.id, 'accepted'),
                        child: const Text('Accept',
                            style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  if (isAccepted) ...[
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _updateStatus(
                            context, vm, booking.id, 'completed'),
                        icon: const Icon(Icons.check_circle_outline,
                            color: Colors.green, size: 18),
                        label: const Text('Complete',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _updateStatus(context, vm, bookingId, status) async {
      final workerId = Supabase.instance.client.auth.currentUser?.id;
      final success = await vm.updateStatus(bookingId, status, workerId: workerId);
      if (success && context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Status updated to $status')),
         );
      }
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
