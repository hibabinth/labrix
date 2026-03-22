import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/message_model.dart';
import '../viewmodel/chat_viewmodel.dart';

class ChatRoomScreen extends StatefulWidget {
  final BookingModel booking;
  const ChatRoomScreen({super.key, required this.booking});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _msgController = TextEditingController();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;

  void _sendMessage(ChatViewModel chatVM) {
    if (_msgController.text.trim().isEmpty) return;
    chatVM.sendMessage(widget.booking.id, _msgController.text.trim());
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Booking #${widget.booking.id.substring(0, 6)}',
          style: const TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatVM.listenToRoom(widget.booking.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet. Say hi!'));
                }

                return ListView.builder(
                  reverse:
                      false, // In practice, reverse is better for chat, but let's keep it simple
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final isMe = messages[index].senderId == _currentUserId;
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.primaryColor : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe
                                ? const Radius.circular(16)
                                : Radius.zero,
                            bottomRight: isMe
                                ? Radius.zero
                                : const Radius.circular(16),
                          ),
                          border: isMe
                              ? null
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          messages[index].content,
                          style: TextStyle(
                            color: isMe
                                ? Colors.white
                                : AppColors.textPrimaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryColor,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _sendMessage(chatVM),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
