import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<BookingModel> _activeChats = [];
  List<BookingModel> get activeChats => _activeChats;

  // Load bookings that are accepted or in progress to show as active chats
  Future<void> loadActiveChats(String userId, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final column = role == 'worker' ? 'worker_id' : 'user_id';

      // We allow users to chat if a booking exists (even if pending)
      final res = await _supabase
          .from('bookings')
          .select()
          .eq(column, userId);

      _activeChats = (res as List)
          .map((e) => BookingModel.fromJson(e))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<MessageModel>> listenToRoom(String bookingId) {
    return _chatRepository.listenToMessages(bookingId);
  }

  Future<void> sendMessage(String bookingId, String content) async {
    final senderId = _supabase.auth.currentUser?.id;
    if (senderId == null) return;

    final message = MessageModel(
      id: const Uuid().v4(),
      bookingId: bookingId,
      senderId: senderId,
      content: content,
    );

    try {
      await _chatRepository.sendMessage(message);
    } catch (e) {
      debugPrint('Failed to send message: $e');
    }
  }
}
