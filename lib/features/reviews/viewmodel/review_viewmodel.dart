import 'package:flutter/material.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/review_repository.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewRepository _repo = ReviewRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<ReviewModel> _workerReviews = [];
  List<ReviewModel> get workerReviews => _workerReviews;

  double get averageRating {
    if (_workerReviews.isEmpty) return 0.0;
    double sum = 0;
    for (var r in _workerReviews) {
      sum += r.rating;
    }
    return sum / _workerReviews.length;
  }

  Future<bool> leaveReview(ReviewModel review) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.leaveReview(review);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadWorkerReviews(String workerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _workerReviews = await _repo.getWorkerReviews(workerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
