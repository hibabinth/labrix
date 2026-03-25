import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/models/worker_model.dart';

class ProfileRepository {
  final _supabase = Supabase.instance.client;

  Future<void> createOrUpdateProfile(ProfileModel profile) async {
    await _supabase.from('profiles').upsert(profile.toJson());
  }

  Future<void> createOrUpdateWorker(WorkerModel worker) async {
    // First ensure profile exists
    final profileData = {
      'id': worker.id,
      'role': worker.role,
      'name': worker.name,
      'phone': worker.phone,
      'location': worker.location,
    };
    await _supabase.from('profiles').upsert(profileData);

    // Then upsert worker specifics
    await _supabase.from('workers').upsert({
      'id': worker.id,
      'category': worker.category,
      'experience_years': worker.experienceYears,
      'price_range': worker.priceRange,
      'is_online': worker.isOnline,
      'is_verified': worker.isVerified,
    });
  }

  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data != null) {
        if (data['role'] == 'worker') {
          final workerData = await _supabase
              .from('workers')
              .select()
              .eq('id', userId)
              .maybeSingle();
          if (workerData != null) {
            final combined = {...data, ...workerData};
            return WorkerModel.fromJson(combined);
          }
        }
        return ProfileModel.fromJson(data);
      }
      return null;
    } catch (e) {
      return null; // Could handle specific errors like PgrstException
    }
  }

  Future<String?> uploadAvatar(String userId, File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final storagePath = 'avatars/$fileName';

      await _supabase.storage.from('avatars').upload(
            storagePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _supabase.storage.from('avatars').getPublicUrl(storagePath);
    } catch (e) {
      return null;
    }
  }

  // --- Utility Mock Actions for Functional Stats ---
  // In a production app, these would probably use RPC functions and junctions tables.
  
  Future<bool> followUser(String targetUserId, String currentUserId) async {
    try {
      // Fetch target's current followers
      final target = await getProfile(targetUserId);
      if (target != null) {
        await _supabase.from('profiles').update({
          'followers': target.followers + 1
        }).eq('id', targetUserId);
      }
      
      // Fetch current user's following
      final current = await getProfile(currentUserId);
      if (current != null) {
        await _supabase.from('profiles').update({
          'following': current.following + 1
        }).eq('id', currentUserId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unfollowUser(String targetUserId, String currentUserId) async {
    try {
      final target = await getProfile(targetUserId);
      if (target != null && target.followers > 0) {
        await _supabase.from('profiles').update({
          'followers': target.followers - 1
        }).eq('id', targetUserId);
      }
      
      final current = await getProfile(currentUserId);
      if (current != null && current.following > 0) {
        await _supabase.from('profiles').update({
          'following': current.following - 1
        }).eq('id', currentUserId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rateWorker(String workerId, double newRating) async {
    try {
      final data = await _supabase.from('workers').select().eq('id', workerId).maybeSingle();
      if (data != null) {
        final currentRating = (data['rating'] ?? 0.0).toDouble();
        final currentCount = data['rating_count'] ?? 0;
        
        final updatedCount = currentCount + 1;
        final updatedRating = ((currentRating * currentCount) + newRating) / updatedCount;

        await _supabase.from('workers').update({
          'rating': updatedRating,
          'rating_count': updatedCount,
        }).eq('id', workerId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
