import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/profile_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final SupabaseClient _supabase = Supabase.instance.client;

  final Map<String, ProfileModel> _participantProfiles = {};
  Map<String, ProfileModel> get participantProfiles => _participantProfiles;

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

  Future<void> fetchParticipantProfiles(String userId, String workerId) async {
    // Only fetch if not already in cache to save requests
    if (!_participantProfiles.containsKey(userId)) {
      final userProfile = await _profileRepository.getProfile(userId);
      if (userProfile != null) {
        _participantProfiles[userId] = userProfile;
      }
    }

    if (!_participantProfiles.containsKey(workerId)) {
      final workerProfile = await _profileRepository.getProfile(workerId);
      if (workerProfile != null) {
        _participantProfiles[workerId] = workerProfile;
      }
    }
    notifyListeners();
  }

  ProfileModel? getOtherParticipantProfile(String bookingId, String currentUserId, {BookingModel? booking}) {
    final targetBooking = booking ?? _activeChats.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => throw Exception('Booking not found in active chats'),
    );
    
    final otherId = targetBooking.userId == currentUserId ? targetBooking.workerId : targetBooking.userId;
    return _participantProfiles[otherId];
  }

  Future<void> deleteChat(String bookingId) async {
    try {
      await _chatRepository.deleteChat(bookingId);
      // We don't necessarily want to remove the booking from list, just clear messages
      // But user said "chat deletion", usually implies removing from list.
      // If we want to hide it, we'd need an 'is_hidden' flag in DB.
      // For now, let's just delete the messages.
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete chat: $e');
    }
  }
}
