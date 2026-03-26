import 'package:flutter/material.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/services/worker_service.dart';

class HomeViewModel extends ChangeNotifier {
  final WorkerService _workerService = WorkerService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Categories come from the local taxonomy — no DB call needed.
  List<CategoryModel> get categories => WorkerCategory.all;

  List<WorkerModel> _workers = [];
  List<WorkerModel> get workers => _workers;

  List<WorkerModel> _filteredWorkers = [];
  List<WorkerModel> get filteredWorkers => _filteredWorkers;

  Future<void> initHome() async {
    _isLoading = true;
    notifyListeners();

    await fetchWorkers();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWorkers() async {
    try {
      final res = await _workerService.getAllWorkers();
      _workers = res.map((e) => WorkerModel.fromJson(e)).toList();
      _filteredWorkers = _workers;
    } catch (e) {
      debugPrint('Error fetching workers: $e');
    }
  }

  /// Filter workers by search query, optional parent [category], and optional [subcategory].
  /// If [subcategory] is provided, matches against the DB `subcategory` field first,
  /// then falls back to the `category` field for parent-level filtering.
  void filterWorkers(String query, String? category, {String? subcategory}) {
    _filteredWorkers = _workers.where((w) {
      final matchesQuery =
          query.isEmpty || w.name.toLowerCase().contains(query.toLowerCase());
      final bool matchesCategory;
      if (subcategory != null) {
        // Match against the DB subcategory field (exact role, e.g. "Mason")
        matchesCategory =
            w.subcategory?.toLowerCase() == subcategory.toLowerCase();
      } else if (category != null) {
        // Match against parent category (e.g. "Construction")
        matchesCategory =
            w.category.toLowerCase() == category.toLowerCase();
      } else {
        matchesCategory = true;
      }
      return matchesQuery && matchesCategory;
    }).toList();
    notifyListeners();
  }

  void clearFilter() {
    _filteredWorkers = _workers;
    notifyListeners();
  }
}
