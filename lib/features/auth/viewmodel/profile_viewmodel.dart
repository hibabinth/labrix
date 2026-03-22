import 'package:flutter/material.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/models/worker_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repo = ProfileRepository();
  bool _isLoading = false;
  ProfileModel? _currentProfile;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  ProfileModel? get currentProfile => _currentProfile;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<void> loadProfile(String userId) async {
    _setLoading(true);
    _currentProfile = await _repo.getProfile(userId);
    _setLoading(false);
  }

  Future<bool> saveUserProfile(ProfileModel profile) async {
    _setLoading(true);
    try {
      await _repo.createOrUpdateProfile(profile);
      _currentProfile = profile;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> saveWorkerProfile(WorkerModel worker) async {
    _setLoading(true);
    try {
      await _repo.createOrUpdateWorker(worker);
      _currentProfile = worker;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
