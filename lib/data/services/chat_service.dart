import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class ChatService {
  final _supabase = Supabase.instance.client;

  Future<void> sendMessage(MessageModel message) async {
    await _supabase.from('messages').insert(message.toJson());
  }

  Stream<List<MessageModel>> listenToMessages(String bookingId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId)
        .order('created_at', ascending: true)
        .map((list) => list.map((e) => MessageModel.fromJson(e)).toList());
  }
}
