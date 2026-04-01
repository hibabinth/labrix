import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodel/admin_viewmodel.dart';
import '../widgets/stat_card.dart';
import 'category_manager_screen.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../auth/view/login_screen.dart';
import '../../../core/theme/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminVM = Provider.of<AdminViewModel>(context, listen: false);
      adminVM.loadUsers();
      adminVM.loadWorkers();
      adminVM.loadPlatformStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminVM = Provider.of<AdminViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryManagerScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await Provider.of<AuthViewModel>(context, listen: false).signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Users'),
            Tab(text: 'Workers'),
          ],
        ),
      ),
      body: adminVM.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(adminVM),
                _buildUsersTab(adminVM),
                _buildWorkersTab(adminVM),
              ],
            ),
    );
  }

  Widget _buildOverviewTab(AdminViewModel adminVM) {
    final stats = adminVM.stats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Platform Stats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          AdminStatCard(
            title: 'Total Users',
            value: (stats['total_users'] ?? 0).toString(),
            icon: Icons.people_outline,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          AdminStatCard(
            title: 'Verified Workers',
            value: (stats['total_workers'] ?? 0).toString(),
            icon: Icons.engineering_outlined,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          AdminStatCard(
            title: 'Pending Verification',
            value: (stats['pending_workers'] ?? 0).toString(),
            icon: Icons.pending_actions_outlined,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          AdminStatCard(
            title: 'Active Bookings',
            value: (stats['total_bookings'] ?? 0).toString(),
            icon: Icons.calendar_month_outlined,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(AdminViewModel adminVM) {
    if (adminVM.users.isEmpty) {
      return const Center(child: Text('No users found.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: adminVM.users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = adminVM.users[index];
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            backgroundImage: user.imageUrl != null ? NetworkImage(user.imageUrl!) : null,
            child: user.imageUrl == null ? const Icon(Icons.person, color: AppColors.primaryColor) : null,
          ),
          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(user.phone),
          trailing: IconButton(
            icon: const Icon(Icons.block, color: Colors.red),
            onPressed: () {
              // Show block confirmation
            },
          ),
        );
      },
    );
  }

  Widget _buildWorkersTab(AdminViewModel adminVM) {
    if (adminVM.workers.isEmpty) {
      return const Center(child: Text('No workers found.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: adminVM.workers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final worker = adminVM.workers[index];
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: CircleAvatar(
            backgroundColor: Colors.orange.withValues(alpha: 0.1),
            backgroundImage: worker.imageUrl != null ? NetworkImage(worker.imageUrl!) : null,
            child: worker.imageUrl == null ? const Icon(Icons.engineering, color: Colors.orange) : null,
          ),
          title: Text(worker.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${worker.category} • ${worker.experienceYears}y exp'),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (worker.idDocumentUrl != null)
                    _buildDocBadge(
                      context,
                      'ID',
                      worker.idDocumentUrl!,
                      Colors.blue,
                    ),
                  if (worker.certDocumentUrl != null) ...[
                    const SizedBox(width: 8),
                    _buildDocBadge(
                      context,
                      'CERT',
                      worker.certDocumentUrl!,
                      Colors.purple,
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Switch(
            value: worker.isVerified,
            activeColor: Colors.green,
            onChanged: (val) {
              adminVM.verifyWorker(worker.id, val);
            },
          ),
        );
      },
    );
  }

  Widget _buildDocBadge(BuildContext context, String label, String url, Color color) {
    return InkWell(
      onTap: () => _viewDocument(context, url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.file_present, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewDocument(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    }
  }
}
