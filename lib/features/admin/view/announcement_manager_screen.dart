import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/admin_viewmodel.dart';
import '../../../data/models/announcement_model.dart';
import '../../../core/theme/app_colors.dart';

class AnnouncementManagerScreen extends StatefulWidget {
  const AnnouncementManagerScreen({super.key});

  @override
  State<AnnouncementManagerScreen> createState() => _AnnouncementManagerScreenState();
}

class _AnnouncementManagerScreenState extends State<AnnouncementManagerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminViewModel>(context, listen: false).loadAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminVM = Provider.of<AdminViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Platform Announcements', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryColor,
        elevation: 0,
      ),
      body: adminVM.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: adminVM.announcements.length,
              itemBuilder: (context, index) {
                final announcement = adminVM.announcements[index];
                return _buildAnnouncementCard(announcement, adminVM);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAnnouncementDialog(context),
        backgroundColor: AppColors.secondaryColor,
        child: const Icon(Icons.add_alert, color: Colors.white),
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel ann, AdminViewModel adminVM) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getRoleColor(ann.targetRole).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                ann.targetRole.toUpperCase(),
                style: TextStyle(
                  color: _getRoleColor(ann.targetRole),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ann.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(ann.message),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => adminVM.deleteAnnouncement(ann.id),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'user':
        return Colors.blue;
      case 'worker':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  void _showAnnouncementDialog(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String targetRole = 'all';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Message'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: targetRole,
                  decoration: const InputDecoration(labelText: 'Target Audience'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Users')),
                    DropdownMenuItem(value: 'user', child: Text('Standard Users')),
                    DropdownMenuItem(value: 'worker', child: Text('Workers Only')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => targetRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final announcement = AnnouncementModel(
                  id: '',
                  title: titleController.text,
                  message: messageController.text,
                  targetRole: targetRole,
                  createdAt: DateTime.now(),
                );
                Provider.of<AdminViewModel>(context, listen: false).saveAnnouncement(announcement);
                Navigator.pop(context);
              },
              child: const Text('Send Broadcast'),
            ),
          ],
        ),
      ),
    );
  }
}
