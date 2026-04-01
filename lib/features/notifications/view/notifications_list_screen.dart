import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/notification_viewmodel.dart';
import 'package:intl/intl.dart';

class NotificationsListScreen extends StatelessWidget {
  const NotificationsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final notificationVM = Provider.of<NotificationViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Notification Hub', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
        actions: [
          if (userId != null)
            TextButton(
              onPressed: () => notificationVM.markAllAsRead(userId),
              child: const Text('Mark all as read', style: TextStyle(fontSize: 12, color: AppColors.primaryColor)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
          }

          if (vm.notifications.isEmpty) {
            return _buildEmptyState();
          }

          final grouped = _groupNotifications(vm.notifications);

          return RefreshIndicator(
            onRefresh: () async {
              if (userId != null) vm.init(userId);
            },
            color: AppColors.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final group = grouped[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
                      child: Text(
                        group.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondaryColor.withOpacity(0.6),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    ...group.items.map((notification) => _buildNotificationCard(context, vm, notification)),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
              ],
            ),
            child: const Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'All caught up!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryColor),
          ),
          const SizedBox(height: 8),
          const Text(
            'You have no new notifications.',
            style: TextStyle(color: AppColors.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationViewModel vm, NotificationModel notification) {
    final iconData = _getIconForType(notification.type);
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => vm.deleteNotification(notification.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) vm.markAsRead(notification.id);
          // Potential: Navigate to related detail screen
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white.withOpacity(0.7) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: notification.isRead ? Colors.grey.shade100 : Colors.blue.shade50),
            boxShadow: [
              if (!notification.isRead)
                BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconData.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData.icon, color: iconData.color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondaryColor.withOpacity(0.8), height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('h:mm a').format(notification.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _IconThemeData _getIconForType(String type) {
    switch (type) {
      case 'booking':
        return _IconThemeData(Icons.calendar_today_rounded, Colors.blue);
      case 'chat':
        return _IconThemeData(Icons.chat_bubble_outline_rounded, Colors.green);
      case 'reminder':
        return _IconThemeData(Icons.alarm_rounded, Colors.orange);
      default:
        return _IconThemeData(Icons.notifications_none_rounded, Colors.grey);
    }
  }

  List<_NotificationGroup> _groupNotifications(List<NotificationModel> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<NotificationModel>> groupsMap = {};

    for (var item in list) {
      final date = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      String key;
      if (date == today) {
        key = 'TODAY';
      } else if (date == yesterday) {
        key = 'YESTERDAY';
      } else {
        key = DateFormat('MMMM dd').format(date).toUpperCase();
      }

      if (!groupsMap.containsKey(key)) {
        groupsMap[key] = [];
      }
      groupsMap[key]!.add(item);
    }

    return groupsMap.entries.map((e) => _NotificationGroup(e.key, e.value)).toList();
  }
}

class _NotificationGroup {
  final String title;
  final List<NotificationModel> items;
  _NotificationGroup(this.title, this.items);
}

class _IconThemeData {
  final IconData icon;
  final Color color;
  _IconThemeData(this.icon, this.color);
}
