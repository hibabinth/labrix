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

  void clearProfile() {
    _currentProfile = null;
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

  Future<String?> uploadAvatar(String userId, dynamic imageFile) async {
    _setLoading(true);
    try {
      final url = await _repo.uploadAvatar(userId, imageFile);
      _setLoading(false);
      return url;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return null;
    }
  }

  Future<String?> uploadCoverImage(String userId, dynamic imageFile) async {
    _setLoading(true);
    try {
      final url = await _repo.uploadCoverImage(userId, imageFile);
      _setLoading(false);
      return url;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return null;
    }
  }

  Future<String?> uploadIDDocument(String userId, dynamic file) async {
    _setLoading(true);
    try {
      final url = await _repo.uploadDocument(userId, 'id_documents', file);
      _setLoading(false);
      return url;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return null;
    }
  }

  Future<String?> uploadCertDocument(String userId, dynamic file) async {
    _setLoading(true);
    try {
      final url = await _repo.uploadDocument(userId, 'cert_documents', file);
      _setLoading(false);
      return url;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return null;
    }
  }

  Future<bool> toggleOnlineStatus(bool val) async {
    if (_currentProfile == null || _currentProfile is! WorkerModel) return false;
    
    final worker = _currentProfile as WorkerModel;
    _setLoading(true);
    try {
      final updatedWorker = WorkerModel(
        id: worker.id,
        role: worker.role,
        name: worker.name,
        phone: worker.phone,
        location: worker.location,
        category: worker.category,
        subcategory: worker.subcategory,
        experienceYears: worker.experienceYears,
        priceRange: worker.priceRange,
        isOnline: val,
        isVerified: worker.isVerified,
        skills: worker.skills,
        education: worker.education,
        portfolioUrls: worker.portfolioUrls,
        imageUrl: worker.imageUrl,
        followers: worker.followers,
        following: worker.following,
        aboutMe: worker.aboutMe,
        interests: worker.interests,
        coverImageUrl: worker.coverImageUrl,
        headline: worker.headline,
        dob: worker.dob,
        rating: worker.rating,
        ratingCount: worker.ratingCount,
        idDocumentUrl: worker.idDocumentUrl,
        certDocumentUrl: worker.certDocumentUrl,
        workingStart: worker.workingStart,
        workingEnd: worker.workingEnd,
        latitude: worker.latitude,
        longitude: worker.longitude,
      );

      await _repo.createOrUpdateWorker(updatedWorker);
      _currentProfile = updatedWorker;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
