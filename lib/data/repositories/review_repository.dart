import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewRepository {
  final ReviewService _reviewService = ReviewService();

  Future<void> leaveReview(ReviewModel review) async {
    await _reviewService.leaveReview(review);
  }

  Future<List<ReviewModel>> getWorkerReviews(String workerId) async {
    return _reviewService.getWorkerReviews(workerId);
  }
}
