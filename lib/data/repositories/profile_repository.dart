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
}
