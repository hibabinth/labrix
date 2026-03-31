import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _supabase = Supabase.instance.client;

  Future<void> initialize() async {
    debugPrint('Notification service initialized (No-op - Firebase removed)');
  }

  Future<String?> getDeviceToken() async {
    return null;
  }

  Future<void> saveTokenToDatabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('user_tokens').upsert({
        'user_id': userId,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Token entry updated');
    } catch (e) {
      debugPrint('Error updating token: $e');
    }
  }
}
