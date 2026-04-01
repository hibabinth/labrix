class MessageModel {
  final String? id;
  final String bookingId;
  final String senderId;
  final String content;
  final String? imageUrl;
  final DateTime? createdAt;

  MessageModel({
    this.id,
    required this.bookingId,
    required this.senderId,
    required this.content,
    this.imageUrl,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      bookingId: json['booking_id'],
      senderId: json['sender_id'],
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'booking_id': bookingId,
      'sender_id': senderId,
      'content': content,
      if (imageUrl != null) 'image_url': imageUrl,
    };
    if (id != null && id!.isNotEmpty) data['id'] = id;
    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();
    return data;
  }
}
