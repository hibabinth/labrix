import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';

class ReviewService {
  final _supabase = Supabase.instance.client;

  Future<void> leaveReview(ReviewModel review) async {
    await _supabase.from('reviews').insert(review.toJson());
  }

  Future<List<ReviewModel>> getWorkerReviews(String workerId) async {
    final res = await _supabase
        .from('reviews')
        .select()
        .eq('worker_id', workerId)
        .order('created_at', ascending: false);
    return (res as List).map((e) => ReviewModel.fromJson(e)).toList();
  }
}
