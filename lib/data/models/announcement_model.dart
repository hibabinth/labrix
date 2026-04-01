class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String targetRole; // 'all', 'user', 'worker'
  final bool isActive;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    this.targetRole = 'all',
    this.isActive = true,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'].toString(),
      title: json['title'] ?? 'Global Message',
      message: json['message'] ?? '',
      targetRole: json['target_role'] ?? 'all',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'target_role': targetRole,
      'is_active': isActive,
    };
  }
}
