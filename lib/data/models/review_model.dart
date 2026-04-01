class ReviewModel {
  final String id;
  final String bookingId;
  final String reviewerId;
  final String workerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? reviewerName;
  final String? reviewerImageUrl;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.workerId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reviewerName,
    this.reviewerImageUrl,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      bookingId: json['booking_id'],
      reviewerId: json['reviewer_id'],
      workerId: json['worker_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      reviewerName: json['profiles']?['name'],
      reviewerImageUrl: json['profiles']?['image_url'],
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
