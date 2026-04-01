import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../../auth/viewmodel/profile_viewmodel.dart';
import '../../../data/models/booking_model.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      final role = profileVM.currentProfile?.role ?? 'user';
      if (userId != null) {
        Provider.of<ChatViewModel>(
          context,
          listen: false,
        ).loadActiveChats(userId, role);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatVM = Provider.of<ChatViewModel>(context);
    final profileVM = Provider.of<ProfileViewModel>(context);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(color: AppColors.textPrimaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: userId == null
          ? const Center(child: Text('Please log in to see messages.'))
          : StreamBuilder<List<BookingModel>>(
              stream: chatVM.getActiveChatsStream(userId, profileVM.currentProfile?.role ?? 'user'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && chatVM.activeChats.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  );
                }
                
                final bookings = snapshot.data ?? chatVM.activeChats;

                if (bookings.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No active chats.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    
                    // Fetch profiles in the background if not cached
                    if (!chatVM.participantProfiles.containsKey(booking.userId) || 
                        !chatVM.participantProfiles.containsKey(booking.workerId)) {
                      chatVM.fetchParticipantProfiles(booking.userId, booking.workerId);
                    }

                    final otherProfile = chatVM.getOtherParticipantProfile(booking.id, userId);

                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                            backgroundImage: (otherProfile?.imageUrl != null && otherProfile!.imageUrl!.isNotEmpty)
                                ? NetworkImage(otherProfile.imageUrl!)
                                : null,
                            child: (otherProfile?.imageUrl == null || otherProfile!.imageUrl!.isEmpty)
                                ? Text(
                                    otherProfile?.name.substring(0, 1).toUpperCase() ?? '?',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                  )
                                : null,
                          ),
                          title: Text(
                            otherProfile?.name ?? 'Loading...',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Booking #${booking.id.substring(0, 6)}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                              Text(
                                'Status: ${booking.status}',
                                style: const TextStyle(color: AppColors.primaryColor, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteConfirmation(context, chatVM, booking.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text('Delete Chat', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatRoomScreen(booking: booking),
                              ),
                            );
                          },
                        ),
                        Divider(height: 1, indent: 88, color: Colors.grey.shade100),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ChatViewModel chatVM, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat?'),
        content: const Text('This will permanently delete all messages in this conversation. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              chatVM.deleteChat(bookingId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat messages deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
