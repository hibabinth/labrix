import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/worker_model.dart';
import '../../../data/repositories/worker_repository.dart';
import '../../../core/services/location_service.dart';

class NearbyWorkersViewModel extends ChangeNotifier {
  final WorkerRepository _workerRepository = WorkerRepository();
  final LocationService _locationService = LocationService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<WorkerModel> _nearbyWorkers = [];
  List<WorkerModel> get nearbyWorkers => _nearbyWorkers;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  double _radiusKm = 10.0; // Default 10km radius
  double get radiusKm => _radiusKm;

  void setRadius(double radius) {
    _radiusKm = radius;
    refreshNearbyWorkers();
  }

  /// Initialize location and load initial workers
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _currentPosition = await _locationService.getCurrentPosition();
    
    if (_currentPosition != null) {
      await refreshNearbyWorkers();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch workers based on current position and radius
  Future<void> refreshNearbyWorkers() async {
    if (_currentPosition == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _nearbyWorkers = await _workerRepository.getNearbyWorkers(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusKm: _radiusKm,
      );
    } catch (e) {
      debugPrint('Error loading nearby workers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Manually update position (e.g., when clicking "My Location")
  Future<void> updateCurrentPosition() async {
    _currentPosition = await _locationService.getCurrentPosition();
    if (_currentPosition != null) {
      await refreshNearbyWorkers();
    }
  }
}
