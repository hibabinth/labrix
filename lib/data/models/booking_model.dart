import 'profile_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String workerId;
  final int? serviceId;
  final String status;
  final DateTime? date;
  final String? time;
  final String? notes;
  final double totalPrice;
  final bool isReviewed;
  final bool reminderSent;
  final ProfileModel? profile; // Joined profile data
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
    this.totalPrice = 500.0,
    this.isReviewed = false,
    this.reminderSent = false,
    this.profile,
    required this.createdAt,
  });

  bool get isUpcoming {
    if (date == null || status != 'accepted') return false;
    final now = DateTime.now();
    return date!.isAfter(now) && date!.difference(now).inDays < 1;
  }

  bool get isToday {
    if (date == null) return false;
    final now = DateTime.now();
    return date!.year == now.year && date!.month == now.month && date!.day == now.day;
  }

  String get remainingTimeSummary {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = date!.difference(now);
    
    if (diff.isNegative) return 'In Progress';
    if (diff.inHours > 0) return 'Starts in ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'Starts in ${diff.inMinutes}m';
    return 'Starts now';
  }

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
      totalPrice: (json['total_price'] ?? 500.0).toDouble(),
      isReviewed: json['is_reviewed'] ?? false,
      reminderSent: json['reminder_sent'] ?? false,
      profile: json['profiles'] != null ? ProfileModel.fromJson(json['profiles']) : null,
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
      'total_price': totalPrice,
      'is_reviewed': isReviewed,
      'reminder_sent': reminderSent,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
