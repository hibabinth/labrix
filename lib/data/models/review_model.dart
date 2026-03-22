class ReviewModel {
  final String id;
  final String bookingId;
  final String reviewerId;
  final String workerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.workerId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      bookingId: json['booking_id'],
      reviewerId: json['reviewer_id'],
      workerId: json['worker_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'reviewer_id': reviewerId,
      'worker_id': workerId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
