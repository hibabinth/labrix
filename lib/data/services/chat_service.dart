import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  Future<void> sendMessage(MessageModel message) async {
    await _supabase.from('messages').insert(message.toJson());
  }

  Future<String?> uploadChatImage(String bookingId, File file) async {
    try {
      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = '$bookingId/$fileName';

      await _supabase.storage.from('chat_media').upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _supabase.storage.from('chat_media').getPublicUrl(path);
    } catch (e) {
      debugPrint('ChatService Error: $e');
      return null;
    }
  }

  Stream<List<MessageModel>> listenToMessages(String bookingId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => MessageModel.fromJson(e)).toList());
  }

  Future<void> deleteMessages(String bookingId) async {
    await _supabase.from('messages').delete().eq('booking_id', bookingId);
  }
}
