class PostModel {
  final String id;
  final String userId;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.text,
    this.imageUrl,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['user_id'],
      text: json['text'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'text': text,
      if (imageUrl != null) 'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
