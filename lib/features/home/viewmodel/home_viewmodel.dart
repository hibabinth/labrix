import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/services/worker_service.dart';

class HomeViewModel extends ChangeNotifier {
  final WorkerService _workerService = WorkerService();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<WorkerModel> _workers = [];
  List<WorkerModel> get workers => _workers;

  List<WorkerModel> _filteredWorkers = [];
  List<WorkerModel> get filteredWorkers => _filteredWorkers;

  Future<void> initHome() async {
    _isLoading = true;
    notifyListeners();

    await fetchCategories();
    await fetchWorkers();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      final res = await _supabase.from('services').select();
      _categories = (res as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
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

  void filterWorkers(String query, String? category) {
    _filteredWorkers = _workers.where((w) {
      final matchesQuery =
          query.isEmpty || w.name.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == null || w.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
    notifyListeners();
  }
}
