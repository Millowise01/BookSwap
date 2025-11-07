class SwapRequest {
  final String? id;
  final String bookOfferedId; // The book the sender wants to give away
  final String bookRequestedId; // The book the sender wants to receive
  final String senderId; // User initiating the swap
  final String senderName;
  final String recipientId; // Owner of the requested book
  final String recipientName;
  final String state; // 'Pending', 'Accepted', 'Rejected'
  final DateTime timestamp;
  final DateTime? respondedAt;

  SwapRequest({
    this.id,
    required this.bookOfferedId,
    required this.bookRequestedId,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    this.state = 'Pending',
    required this.timestamp,
    this.respondedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookOfferedId': bookOfferedId,
      'bookRequestedId': bookRequestedId,
      'senderId': senderId,
      'senderName': senderName,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'state': state,
      'timestamp': timestamp.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  factory SwapRequest.fromJson(Map<String, dynamic> json, String id) {
    return SwapRequest(
      id: id,
      bookOfferedId: json['bookOfferedId'] as String,
      bookRequestedId: json['bookRequestedId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      recipientId: json['recipientId'] as String,
      recipientName: json['recipientName'] as String,
      state: json['state'] as String? ?? 'Pending',
      timestamp: DateTime.parse(json['timestamp'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }

  SwapRequest copyWith({
    String? id,
    String? bookOfferedId,
    String? bookRequestedId,
    String? senderId,
    String? senderName,
    String? recipientId,
    String? recipientName,
    String? state,
    DateTime? timestamp,
    DateTime? respondedAt,
  }) {
    return SwapRequest(
      id: id ?? this.id,
      bookOfferedId: bookOfferedId ?? this.bookOfferedId,
      bookRequestedId: bookRequestedId ?? this.bookRequestedId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      state: state ?? this.state,
      timestamp: timestamp ?? this.timestamp,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

