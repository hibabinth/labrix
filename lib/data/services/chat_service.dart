import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  Future<void> sendMessage(MessageModel message) async {
    await _supabase.from('messages').insert(message.toJson());
  }

  Stream<List<MessageModel>> listenToMessages(String bookingId) {
    late RealtimeChannel channel;
    final controller = StreamController<List<MessageModel>>();
    List<MessageModel> messages = [];

    // 1. Fetch initial messages
    _supabase
        .from('messages')
        .select()
        .eq('booking_id', bookingId)
        .order('created_at', ascending: false)
        .then((data) {
      messages = (data as List).map((e) => MessageModel.fromJson(e)).toList();
      controller.add(messages);
    });

    // 2. Subscribe to realtime changes
    channel = _supabase.channel('public:messages:booking=$bookingId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'booking_id',
        value: bookingId,
      ),
      callback: (payload) {
        if (payload.eventType == PostgresChangeEvent.insert) {
          debugPrint('ChatService: Realtime INSERT received: ${payload.newRecord}');
          final newMessage = MessageModel.fromJson(payload.newRecord);
          // Check if message already exists (prevent duplicates from racing conditions)
          if (!messages.any((m) => m.id == newMessage.id)) {
            messages.insert(0, newMessage);
            // Sort to ensure correct order
            messages.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            controller.add(List.from(messages));
          }
        }
      },
    ).subscribe();

    controller.onCancel = () {
      channel.unsubscribe();
      controller.close();
    };

    return controller.stream;
  }
}
