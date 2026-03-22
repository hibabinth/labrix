class JobApplicationModel {
  final String id;
  final String jobVacancyId;
  final String workerId;
  final String coverLetter;
  final double proposedPrice;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  JobApplicationModel({
    required this.id,
    required this.jobVacancyId,
    required this.workerId,
    required this.coverLetter,
    required this.proposedPrice,
    required this.status,
    required this.createdAt,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] as String,
      jobVacancyId: json['job_vacancy_id'] as String,
      workerId: json['worker_id'] as String,
      coverLetter: json['cover_letter'] as String,
      proposedPrice: (json['proposed_price'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_vacancy_id': jobVacancyId,
      'worker_id': workerId,
      'cover_letter': coverLetter,
      'proposed_price': proposedPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
