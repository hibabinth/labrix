import 'package:flutter/material.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/models/announcement_model.dart';
import '../../../data/repositories/notification_repository.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminRepository _repo = AdminRepository();
  final NotificationRepository _notificationRepo = NotificationRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ProfileModel> _users = [];
  List<ProfileModel> get users => _users;

  List<WorkerModel> _workers = [];
  List<WorkerModel> get workers => _workers;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<AnnouncementModel> _announcements = [];
  List<AnnouncementModel> get announcements => _announcements;

  List<ProfileModel> _allProfiles = [];
  List<ProfileModel> get allProfiles => _allProfiles;

  List<ProfileModel> _filteredProfiles = [];
  List<ProfileModel> get filteredProfiles => _filteredProfiles;

  Map<String, dynamic> _stats = {};
  Map<String, dynamic> get stats => _stats;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // ── User Management ───────────────────

  Future<void> loadUsers() async {
    _setLoading(true);
    try {
      _users = await _repo.getProfilesByRole(ProfileModel.roleUser);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> toggleUserRole(String userId, String newRole) async {
    try {
      await _repo.updateUserRole(userId, newRole);
      await loadUsers(); // Refresh list
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Worker Management ─────────────────

  Future<void> loadWorkers() async {
    _setLoading(true);
    try {
      _workers = await _repo.getAllWorkers();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> verifyWorker(String workerId, bool isVerified) async {
    try {
      await _repo.updateWorkerVerificationStatus(workerId, isVerified);
      
      // Notify the worker if they just got verified
      if (isVerified) {
        await _notificationRepo.sendNotification(
          userId: workerId,
          title: '🎉 Profile Verified!',
          message: 'Congratulations! Your professional profile is now verified and live for all users to see.',
        );
      }
      
      await loadWorkers(); // Refresh list
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Category Management ───────────────

  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      final res = await _repo.getCategories();
      _categories = (res as List).map((e) => CategoryModel.fromJson(e)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> saveCategory(String name, String emoji, List<String> subs) async {
    _setLoading(true);
    try {
      await _repo.upsertCategory(name, emoji, subs);
      await loadCategories();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> deleteCategory(String name) async {
    _setLoading(true);
    try {
      await _repo.deleteCategory(name);
      await loadCategories();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  // ── Announcement Management ───────────

  Future<void> loadAnnouncements() async {
    _setLoading(true);
    try {
      final res = await _repo.getAnnouncements();
      _announcements = (res as List).map((e) => AnnouncementModel.fromJson(e)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> saveAnnouncement(AnnouncementModel announcement) async {
    _setLoading(true);
    try {
      await _repo.upsertAnnouncement(announcement.toJson());
      await loadAnnouncements();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> deleteAnnouncement(String id) async {
    _setLoading(true);
    try {
      await _repo.deleteAnnouncement(id);
      await loadAnnouncements();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  // ── Super Admin Analytics ──────────────

  Future<Map<String, dynamic>> loadPlatformStats() async {
    _isLoading = true;
    notifyListeners();
    _stats = await _repo.getPlatformStats();
    _isLoading = false;
    notifyListeners();
    return _stats;
  }

  // ── Global Role Management ───────────

  Future<void> loadAllProfiles() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allProfiles = await _repo.getAllProfilesGlobal();
      _filteredProfiles = _allProfiles;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void searchProfiles(String query) {
    if (query.isEmpty) {
      _filteredProfiles = _allProfiles;
    } else {
      _filteredProfiles = _allProfiles.where((p) => 
        p.name.toLowerCase().contains(query.toLowerCase()) ||
        (p.email?.toLowerCase() ?? '').contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _repo.updateUserRole(userId, newRole);
      // Update local state without full reload
      final index = _allProfiles.indexWhere((p) => p.id == userId);
      if (index != -1) {
        // Since we don't have a copyWith for ProfileModel, we reload for safety
        await loadAllProfiles();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
