class PaymentModel {
  final String id;
  final String bookingId;
  final double amount;
  final String method;
  final String status;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      bookingId: json['booking_id'],
      amount: double.parse(json['amount'].toString()),
      method: json['method'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'method': method,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
