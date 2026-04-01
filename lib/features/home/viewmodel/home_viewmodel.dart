import 'package:flutter/material.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/announcement_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/services/worker_service.dart';

class HomeViewModel extends ChangeNotifier {
  final WorkerService _workerService = WorkerService();
  final AdminRepository _adminRepo = AdminRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ✅ Dynamic categories (from workers)
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  // Workers list
  List<WorkerModel> _workers = [];
  List<WorkerModel> get workers => _workers;

  // Filtered workers
  List<WorkerModel> _filteredWorkers = [];
  List<WorkerModel> get filteredWorkers => _filteredWorkers;

  List<AnnouncementModel> _announcements = [];
  List<AnnouncementModel> get announcements => _announcements;

  // 🔄 Initialize Home
  Future<void> initHome(String? userRole) async {
    if (_isLoading) return; // Prevent concurrent initializations

    _isLoading = true;
    // Delay notifyListeners slightly or move to post frame if called from build
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    await fetchWorkers();
    await fetchCategories();
    if (userRole != null) {
      await fetchAnnouncements(userRole);
    }

    _isLoading = false;
    notifyListeners();
  }

  // 📦 Fetch announcements
  Future<void> fetchAnnouncements(String userRole) async {
    try {
      final res = await _adminRepo.getAnnouncements();
      final allAnn = (res as List).map((e) => AnnouncementModel.fromJson(e)).toList();
      
      // Filter by role: 'all' or specific role
      _announcements = allAnn.where((ann) => 
        ann.isActive && (ann.targetRole == 'all' || ann.targetRole == userRole)
      ).toList();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    }
    notifyListeners();
  }

  // 📦 Fetch workers from DB
  Future<void> fetchWorkers() async {
    try {
      final res = await _workerService.getAllWorkers();

      _workers = res.map((e) => WorkerModel.fromJson(e)).toList();
      _filteredWorkers = _workers;
    } catch (e) {
      debugPrint('Error fetching workers: $e');
    }
  }

  // 📦 Fetch dynamic categories from DB
  Future<void> fetchCategories() async {
    try {
      final res = await _adminRepo.getCategories();
      if (res.isNotEmpty) {
        _categories = res.map((e) => CategoryModel.fromJson(e)).toList();
      } else {
        _buildCategoriesFromWorkers(); // Fallback
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      _buildCategoriesFromWorkers(); // Fallback
    }
    notifyListeners();
  }

  // 🔥 BUILD CATEGORIES FROM WORKERS (MAIN FIX)
  void _buildCategoriesFromWorkers() {
    final Map<String, Set<String>> map = {};

    for (var w in _workers) {
      final category = w.category;
      final sub = w.subcategory ?? '';

      if (!map.containsKey(category)) {
        map[category] = {};
      }

      if (sub.isNotEmpty) {
        map[category]!.add(sub);
      }
    }

    int idCounter = 1;

    _categories = map.entries.map((e) {
      return CategoryModel(
        id: idCounter++, // ✅ FIX FOR YOUR MODEL
        name: e.key,
        emoji: _getEmoji(e.key),
        subcategories: e.value.toList(),
      );
    }).toList();

    notifyListeners();
  }

  // 🎨 Emoji helper (optional)
  String _getEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'construction':
        return '🔨';
      case 'plumbing':
        return '🚰';
      case 'electrician':
        return '⚡';
      case 'cleaning':
        return '🧹';
      case 'welding':
        return '🔥';
      case 'carpentry':
        return '🪵';
      default:
        return '🛠️';
    }
  }

  /// 🔍 Filter workers by search + category + subcategory
  void filterWorkers(String query, String? category, {String? subcategory}) {
    _filteredWorkers = _workers.where((w) {
      final matchesQuery =
          query.isEmpty || w.name.toLowerCase().contains(query.toLowerCase());

      final bool matchesCategory;

      if (subcategory != null) {
        matchesCategory =
            w.subcategory?.toLowerCase() == subcategory.toLowerCase();
      } else if (category != null) {
        matchesCategory = w.category.toLowerCase() == category.toLowerCase();
      } else {
        matchesCategory = true;
      }

      return matchesQuery && matchesCategory;
    }).toList();

    notifyListeners();
  }

  // 🔄 Reset filters
  void clearFilter() {
    _filteredWorkers = _workers;
    notifyListeners();
  }
}
