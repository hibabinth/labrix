import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/viewmodel/profile_viewmodel.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/models/worker_model.dart';
import '../viewmodel/home_viewmodel.dart';
import '../../../shared/widgets/announcement_banner.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/models/booking_model.dart';
import '../../chat/view/chat_room_screen.dart';
import '../../chat/viewmodel/chat_viewmodel.dart';
import '../../../shared/widgets/notification_bell.dart';
import 'package:intl/intl.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final BookingRepository _bookingRepo = BookingRepository();
  List<BookingModel>? _bookings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
    final profile = profileVM.currentProfile;
    if (profile != null) {
      if (mounted) setState(() => _isLoading = true);
      
      // ✅ NEW: Initialize announcements/categories via HomeViewModel
      await Provider.of<HomeViewModel>(context, listen: false).initHome(profile.role);

      final data = await _bookingRepo.getWorkerBookings(profile.id);
      if (mounted) {
        setState(() {
          _bookings = data;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    final profile = profileVM.currentProfile;
    final workerName = profile?.name.split(' ').first ?? 'Worker';

    final bookings = _bookings ?? [];
    final totalBookings = bookings.where((b) => b.status.toLowerCase() != 'cancelled').length;
    final completedBookings = bookings.where((b) => b.status.toLowerCase() == 'completed').length;
    final totalEarnings = completedBookings * 500;
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primaryColor,
        child: CustomScrollView(
          slivers: [
            // ── App Bar / Header ─────────────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryColor, Color(0xFF1A237E)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$workerName! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (profile is WorkerModel) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: profile.isOnline ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: profile.isOnline ? Colors.green : Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, color: profile.isOnline ? Colors.green : Colors.grey.shade400, size: 10),
                                const SizedBox(width: 6),
                                Text(
                                  profile.isOnline ? 'ON DUTY' : 'CURRENTLY AWAY',
                                  style: TextStyle(
                                    color: profile.isOnline ? Colors.green : Colors.white.withOpacity(0.8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                if (profile is WorkerModel)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          profile.isOnline ? 'On Duty' : 'Away',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: profile.isOnline,
                          activeColor: Colors.green,
                          activeTrackColor: Colors.green.withOpacity(0.3),
                          inactiveThumbColor: Colors.grey.shade300,
                          inactiveTrackColor: Colors.white24,
                          onChanged: (val) => profileVM.toggleOnlineStatus(val),
                        ),
                      ],
                    ),
                  ),
                const NotificationBell(),
                const SizedBox(width: 8),
              ],
            ),

            // ── Announcements ────────────────────────────────
            Consumer<HomeViewModel>(
              builder: (context, homeVM, child) {
                if (homeVM.announcements.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverToBoxAdapter(
                  child: AnnouncementBanner(announcements: homeVM.announcements),
                );
              },
            ),

            // ── Stats Summary ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Overview'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total Bookings',
                            value: _isLoading ? '...' : totalBookings.toString(),
                            icon: Icons.calendar_today,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total Earnings',
                            value: _isLoading ? '...' : formatter.format(totalEarnings),
                            icon: Icons.account_balance_wallet,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Bookings Feed'),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Bookings List ────────────────────────────────────────
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  ),
                ),
              )
            else if (bookings.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'No bookings found',
                          style: TextStyle(color: AppColors.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final booking = bookings[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Consumer<ChatViewModel>(
                        builder: (context, chatVM, child) {
                          if (!chatVM.participantProfiles.containsKey(booking.userId)) {
                            chatVM.fetchParticipantProfiles(booking.userId, booking.workerId);
                          }
                          final customerProfile = chatVM.participantProfiles[booking.userId];
                          return _buildBookingCard(booking, customerProfile);
                        },
                      ),
                    );
                  },
                  childCount: bookings.length,
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking, ProfileModel? customerProfile) {
    final dateStr = booking.date != null ? DateFormat('MMM dd, yyyy').format(booking.date!) : 'No date';
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(booking: booking),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              backgroundImage: (customerProfile?.imageUrl != null && customerProfile!.imageUrl!.isNotEmpty)
                  ? NetworkImage(customerProfile.imageUrl!)
                  : null,
              child: (customerProfile?.imageUrl == null || customerProfile!.imageUrl!.isEmpty)
                  ? Text(
                      customerProfile?.name.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      customerProfile?.name ?? 'Customer Request',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (booking.isUpcoming) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.alarm, size: 12, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(
                              booking.remainingTimeSummary,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '$dateStr at ${booking.time ?? "Anytime"}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                    Text(
                      'Booking #${booking.id.substring(0, 6).toUpperCase()}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                booking.status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(booking.status),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
