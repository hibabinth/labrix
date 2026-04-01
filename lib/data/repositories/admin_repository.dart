import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../models/worker_model.dart';

class AdminRepository {
  final _supabase = Supabase.instance.client;

  // ── User Management ───────────────────

  /// Fetches all users (standard customers - hirers)
  Future<List<ProfileModel>> getAllUsers() async {
    final res = await _supabase
        .from('profiles')
        .select()
        .eq('role', ProfileModel.roleUser);
    return (res as List).map((e) => ProfileModel.fromJson(e)).toList();
  }

  /// Fetches all profiles with a specific role
  Future<List<ProfileModel>> getProfilesByRole(String role) async {
    final res = await _supabase.from('profiles').select().eq('role', role);
    return (res as List).map((e) => ProfileModel.fromJson(e)).toList();
  }

  /// Updates a user's role (Super Admin action)
  Future<void> updateUserRole(String userId, String newRole) async {
    await _supabase.from('profiles').update({'role': newRole}).eq('id', userId);
  }

  /// Fetches ALL profiles (Super Admin search)
  Future<List<ProfileModel>> getAllProfilesGlobal() async {
    final res = await _supabase.from('profiles').select().order('name', ascending: true);
    return (res as List).map((e) => ProfileModel.fromJson(e)).toList();
  }

  // ── Worker Management ─────────────────

  /// Fetches all workers with their profile and worker-specific data
  Future<List<WorkerModel>> getAllWorkers() async {
    // We select from profiles to ensure we see everyone who HAS the worker role
    final List res = await _supabase
        .from('profiles')
        .select('*, workers(*)')
        .eq('role', ProfileModel.roleWorker);
    
    return res.map((e) {
      final workerList = e['workers'] as List?;
      // If the worker-specific table entry doesn't exist yet, we use empty defaults
      final workerData = (workerList != null && workerList.isNotEmpty) 
          ? workerList[0] 
          : {
              'category': 'Incomplete Setup',
              'experience_years': 0,
              'price_range': 'N/A',
              'is_online': false,
              'is_verified': false,
            };
            
      final combined = Map<String, dynamic>.from(e)..addAll(Map<String, dynamic>.from(workerData));
      return WorkerModel.fromJson(combined);
    }).toList();
  }

  /// Verification/Approval for Workers
  Future<void> updateWorkerVerificationStatus(String workerId, bool isVerified) async {
    await _supabase.from('workers').update({'is_verified': isVerified}).eq('id', workerId);
  }

  // ── Category Management ───────────────

  /// Fetches all categories from the database
  Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await _supabase
        .from('categories')
        .select()
        .order('priority', ascending: true);
    return List<Map<String, dynamic>>.from(res as List);
  }

  /// Updates or Creates a Category
  Future<void> upsertCategory(String name, String emoji, List<String> subcategories) async {
    await _supabase.from('categories').upsert({
      'name': name,
      'emoji': emoji,
      'subcategories': subcategories,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'name');
  }

  /// Deletes a category by name
  Future<void> deleteCategory(String name) async {
    await _supabase.from('categories').delete().eq('name', name);
  }

  // ── Announcement Management ───────────

  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final res = await _supabase
        .from('announcements')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res as List);
  }

  Future<void> upsertAnnouncement(Map<String, dynamic> data) async {
    await _supabase.from('announcements').upsert(data);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _supabase.from('announcements').delete().eq('id', id);
  }

  // ── Platform Analytics (Super Admin) ─

  Future<Map<String, dynamic>> getPlatformStats() async {
    try {
      final usersRes = await _supabase.from('profiles').select('id');
      
      // Only count workers who are ACTUALLY verified in the workers table
      final verifiedWorkersRes = await _supabase
          .from('workers')
          .select('id')
          .eq('is_verified', true);
          
      // Also count pending workers
      final pendingWorkersRes = await _supabase
          .from('workers')
          .select('id')
          .eq('is_verified', false);

      // Total bookings & revenue
      int bookingsCount = 0;
      double totalRevenue = 0;
      try {
        final bookingsRes = await _supabase.from('bookings').select('total_price, status');
        final bookingsList = bookingsRes as List;
        bookingsCount = bookingsList.length;
        
        // Sum up total price for completed bookings (Revenue)
        for (var b in bookingsList) {
          if (b['status'] == 'completed') {
            totalRevenue += (b['total_price'] ?? 0).toDouble();
          }
        }
      } catch (_) {}

      return {
        'total_users': (usersRes as List).length,
        'total_workers': (verifiedWorkersRes as List).length,
        'pending_workers': (pendingWorkersRes as List).length,
        'total_bookings': bookingsCount,
        'total_revenue': totalRevenue,
      };
    } catch (e) {
      debugPrint('Error fetching platform stats: $e');
      return {
        'total_users': 0,
        'total_workers': 0,
        'pending_workers': 0,
        'total_bookings': 0,
        'total_revenue': 0,
      };
    }
  }
}
