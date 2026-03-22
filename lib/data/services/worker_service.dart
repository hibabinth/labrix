import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getWorkerProfile(String userId) async {
    try {
      return await _supabase
          .from('workers')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      return null;
    }
  }

  Future<void> upsertWorkerProfile(Map<String, dynamic> data) async {
    await _supabase.from('workers').upsert(data);
  }

  Future<List<Map<String, dynamic>>> getAllWorkers() async {
    final res = await _supabase.from('workers').select('*, profiles(*)');
    return List<Map<String, dynamic>>.from(res);
  }
}
