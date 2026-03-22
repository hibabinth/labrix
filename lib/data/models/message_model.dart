class MessageModel {
  final String id;
  final String bookingId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      bookingId: json['booking_id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'sender_id': senderId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
