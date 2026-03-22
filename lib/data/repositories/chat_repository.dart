import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatRepository {
  final ChatService _chatService = ChatService();

  Future<void> sendMessage(MessageModel message) async {
    await _chatService.sendMessage(message);
  }

  Stream<List<MessageModel>> listenToMessages(String bookingId) {
    return _chatService.listenToMessages(bookingId);
  }
}
