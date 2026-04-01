import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/worker_model.dart';

class WorkerRepository {
  final _supabase = Supabase.instance.client;

  /// Fetch workers within a certain radius using the custom RPC function.
  Future<List<WorkerModel>> getNearbyWorkers({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      // Call the RPC function we defined in Supabase
      final List<dynamic> response = await _supabase.rpc(
        'get_nearby_workers',
        params: {
          'user_lat': latitude,
          'user_long': longitude,
          'radius_km': radiusKm,
        },
      );

      // Now join with the 'workers' table to get the professional details
      // Since the RPC returns 'profiles', we need to fetch the worker data for those IDs
      final List<String> workerIds = response.map((p) => p['id'] as String).toList();
      
      if (workerIds.isEmpty) return [];

      final workerDetails = await _supabase
          .from('workers')
          .select('*, profiles:id(*)')
          .inFilter('id', workerIds);

      return (workerDetails as List)
          .map((w) => WorkerModel.fromJson(w))
          .toList();
    } catch (e) {
      print('Error fetching nearby workers: $e');
      return [];
    }
  }

  /// Get all verified workers (standard search)
  Future<List<WorkerModel>> getAllWorkers() async {
    final res = await _supabase
        .from('workers')
        .select('*, profiles:id(*)')
        .eq('is_verified', true);
    return (res as List).map((e) => WorkerModel.fromJson(e)).toList();
  }
}
