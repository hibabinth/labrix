class BookingModel {
  final String id;
  final String userId;
  final String workerId;
  final int? serviceId;
  final String status;
  final DateTime? date;
  final String? time;
  final String? notes;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.workerId,
    this.serviceId,
    required this.status,
    this.date,
    this.time,
    this.notes,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      userId: json['user_id'],
      workerId: json['worker_id'],
      serviceId: json['service_id'],
      status: json['status'] ?? 'pending',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      time: json['time'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'worker_id': workerId,
      'service_id': serviceId,
      'status': status,
      'date': date?.toIso8601String(),
      'time': time,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
