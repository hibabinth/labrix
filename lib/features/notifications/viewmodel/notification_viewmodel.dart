import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  StreamSubscription? _subscription;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  // Initialize and listen to notifications
  void init(String userId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repo.getNotificationStream(userId).listen((data) {
      _notifications = data;
      _unreadCount = data.where((n) => !n.isRead).length;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    // Realtime stream will update the UI automatically
  }

  Future<void> markAllAsRead(String userId) async {
    await _repo.markAllAsRead(userId);
    // Realtime stream will update the UI automatically
  }

  Future<void> deleteNotification(String id) async {
    await _repo.deleteNotification(id);
    // Realtime stream will update the UI automatically
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
