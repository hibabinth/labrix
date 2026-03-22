import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      return await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      return null;
    }
  }

  Future<void> upsertUserProfile(Map<String, dynamic> data) async {
    await _supabase.from('profiles').upsert(data);
  }
}
