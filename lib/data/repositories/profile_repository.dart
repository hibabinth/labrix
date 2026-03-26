import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/models/worker_model.dart';

class ProfileRepository {
  final _supabase = Supabase.instance.client;

  Future<void> createOrUpdateProfile(ProfileModel profile) async {
    await _supabase.from('profiles').upsert(profile.toProfileJson());
  }

  Future<void> createOrUpdateWorker(WorkerModel worker) async {
    // Upsert the base profile fields first (guarantees profile exists)
    await _supabase.from('profiles').upsert(worker.toProfileJson());

    // Then upsert worker-specific fields
    await _supabase.from('workers').upsert({
      'id': worker.id,
      'category': worker.category,
      'experience_years': worker.experienceYears,
      'price_range': worker.priceRange,
      'is_online': worker.isOnline,
      'is_verified': worker.isVerified,
      'skills': worker.skills,
      if (worker.education != null) 'education': worker.education,
      'portfolio_urls': worker.portfolioUrls,
      'rating': worker.rating,
      'rating_count': worker.ratingCount,
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

  Future<String?> uploadCoverImage(String userId, File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final storagePath = 'covers/$fileName';

      await _supabase.storage.from('covers').upload(
            storagePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _supabase.storage.from('covers').getPublicUrl(storagePath);
    } catch (e) {
      return null;
    }
  }

  // --- Relational Follower Actions ---

  Future<bool> followUser(String targetUserId, String currentUserId) async {
    try {
      await _supabase.from('user_follows').insert({
        'follower_id': currentUserId,
        'following_id': targetUserId,
      });
      return true;
    } catch (e) {
      return false; // Could be uniqueness error if already followed
    }
  }

  Future<bool> unfollowUser(String targetUserId, String currentUserId) async {
    try {
      await _supabase.from('user_follows').delete()
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIsFollowing(String targetUserId, String currentUserId) async {
    try {
      final data = await _supabase.from('user_follows')
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId)
          .maybeSingle();
      return data != null;
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
