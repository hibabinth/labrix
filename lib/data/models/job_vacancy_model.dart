class JobVacancyModel {
  final String id;
  final String userId; // The Hirer who posted it
  final String title;
  final String description;
  final String category;
  final String location;
  final double budget;
  final DateTime dateNeeded;
  final String status; // 'open', 'assigned', 'completed', 'cancelled'
  final DateTime createdAt;
  final String? assignedWorkerId;

  JobVacancyModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.budget,
    required this.dateNeeded,
    required this.status,
    required this.createdAt,
    this.assignedWorkerId,
  });

  factory JobVacancyModel.fromJson(Map<String, dynamic> json) {
    return JobVacancyModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      location: json['location'] as String,
      budget: (json['budget'] as num).toDouble(),
      dateNeeded: DateTime.parse(json['date_needed'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      assignedWorkerId: json['assigned_worker_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'budget': budget,
      'date_needed': dateNeeded.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'assigned_worker_id': assignedWorkerId,
    };
  }
}
