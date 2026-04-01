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
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;
  late Stream<List<MessageModel>> _messageStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final chatVM = Provider.of<ChatViewModel>(context, listen: false);
      _messageStream = chatVM.listenToRoom(widget.booking.id);
      
      // Fetch profiles for both participants
      chatVM.fetchParticipantProfiles(widget.booking.userId, widget.booking.workerId);
      
      // Force initial rebuild once stream is set
      setState(() {});
    });
  }

  void _sendMessage(ChatViewModel chatVM) {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    
    // Clear immediately for "Instant" feel
    _msgController.clear();
    
    // Send in background
    chatVM.sendMessage(widget.booking.id, text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, chatVM, child) {
        final otherProfile = chatVM.getOtherParticipantProfile(
          widget.booking.id, 
          _currentUserId, 
          booking: widget.booking,
        );

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  backgroundImage: (otherProfile?.imageUrl != null && otherProfile!.imageUrl!.isNotEmpty)
                      ? NetworkImage(otherProfile.imageUrl!)
                      : null,
                  child: (otherProfile?.imageUrl == null || otherProfile!.imageUrl!.isEmpty)
                      ? Text(
                          otherProfile?.name.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherProfile?.name ?? 'Loading...',
                        style: const TextStyle(
                          color: AppColors.textPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Booking #${widget.booking.id.substring(0, 6)}',
                        style: TextStyle(
                          color: AppColors.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            elevation: 1,
            iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<MessageModel>>(
                  stream: _messageStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final messages = snapshot.data ?? [];
                    
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut);
                      }
                    });

                    if (messages.isEmpty) {
                      return const Center(child: Text('No messages yet. Say hi!'));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == _currentUserId;
                        final senderProfile = chatVM.participantProfiles[message.senderId];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe) ...[
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                                  backgroundImage: (senderProfile?.imageUrl != null && senderProfile!.imageUrl!.isNotEmpty)
                                      ? NetworkImage(senderProfile.imageUrl!)
                                      : null,
                                  child: (senderProfile?.imageUrl == null || senderProfile!.imageUrl!.isEmpty)
                                      ? Text(
                                          senderProfile?.name.substring(0, 1).toUpperCase() ?? '?',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Container(
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
                                            : Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: message.imageUrl != null 
                                          ? GestureDetector(
                                              onTap: () => _viewImage(message.imageUrl!),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  message.imageUrl!,
                                                  width: 200,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return Container(
                                                      width: 200,
                                                      height: 150,
                                                      color: Colors.grey.shade200,
                                                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                                    );
                                                  },
                                                ),
                                              ),
                                            )
                                          : Text(
                                              message.content,
                                              style: TextStyle(
                                                color: isMe
                                                    ? Colors.white
                                                    : AppColors.textPrimaryColor,
                                              ),
                                            ),
                                    ),
                              ),
                            ],
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
                      IconButton(
                        icon: const Icon(Icons.image_outlined, color: AppColors.primaryColor),
                        onPressed: () => chatVM.pickAndSendImage(widget.booking.id),
                      ),
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
              if (chatVM.isUploading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Sending photo...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _viewImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
          body: Center(child: InteractiveViewer(child: Image.network(url))),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
