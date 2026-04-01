import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  final Map<String, ProfileModel> _participantProfiles = {};
  Map<String, ProfileModel> get participantProfiles => _participantProfiles;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<BookingModel> _activeChats = [];
  List<BookingModel> get activeChats => _activeChats;

  // 🔄 Live stream of active conversations (Bookings)
  Stream<List<BookingModel>> getActiveChatsStream(String userId, String role) {
    final column = role == 'worker' ? 'worker_id' : 'user_id';
    
    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq(column, userId)
        .order('created_at', ascending: false)
        .map((data) {
          final list = data.map((e) => BookingModel.fromJson(e)).toList();
          _activeChats = list; // Sync local list for profile lookups
          return list;
        });
  }

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

  Future<void> pickAndSendImage(String bookingId) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compression for mobile performance
    );

    if (image == null) return;

    _isUploading = true;
    notifyListeners();

    try {
      final imageUrl = await _chatRepository.uploadChatImage(bookingId, File(image.path));
      
      if (imageUrl != null) {
        final senderId = _supabase.auth.currentUser?.id;
        if (senderId == null) return;

        final message = MessageModel(
          id: const Uuid().v4(),
          bookingId: bookingId,
          senderId: senderId,
          content: '', // Empty content for image-only messages
          imageUrl: imageUrl,
        );

        await _chatRepository.sendMessage(message);
      }
    } catch (e) {
      debugPrint('Failed to send image: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> fetchParticipantProfiles(String userId, String workerId) async {
    // Only fetch if not already in cache to save requests
    bool changed = false;
    if (!_participantProfiles.containsKey(userId)) {
      final userProfile = await _profileRepository.getProfile(userId);
      if (userProfile != null) {
        _participantProfiles[userId] = userProfile;
        changed = true;
      }
    }

    if (!_participantProfiles.containsKey(workerId)) {
      final workerProfile = await _profileRepository.getProfile(workerId);
      if (workerProfile != null) {
        _participantProfiles[workerId] = workerProfile;
        changed = true;
      }
    }
    
    if (changed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  ProfileModel? getOtherParticipantProfile(String bookingId, String currentUserId, {BookingModel? booking}) {
    try {
      final targetBooking = booking ?? _activeChats.firstWhere(
        (b) => b.id == bookingId,
      );
      
      final otherId = targetBooking.userId == currentUserId ? targetBooking.workerId : targetBooking.userId;
      return _participantProfiles[otherId];
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteChat(String bookingId) async {
    try {
      // 1. Optimistic Update: Remove from local list immediately
      _activeChats.removeWhere((b) => b.id == bookingId);
      notifyListeners();

      // 2. Perform DB deletion
      await _chatRepository.deleteChat(bookingId);
    } catch (e) {
      debugPrint('Failed to delete chat: $e');
    }
  }
}
