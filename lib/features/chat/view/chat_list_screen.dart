import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../../auth/viewmodel/profile_viewmodel.dart';
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

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: chatVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : chatVM.activeChats.isEmpty
          ? const Center(
              child: Text(
                'No active chats.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryColor,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatVM.activeChats.length,
              itemBuilder: (context, index) {
                final booking = chatVM.activeChats[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    title: Text(
                      'Booking #${booking.id.substring(0, 6)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Status: ${booking.status}',
                      style: const TextStyle(color: AppColors.primaryColor),
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
                );
              },
            ),
    );
  }
}
