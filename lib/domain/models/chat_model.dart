import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String? id;
  final List<String> participants;
  final String participant1Id;
  final String participant1Name;
  final String participant2Id;
  final String participant2Name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final DateTime createdAt;
  final String swapRequestId; // Link to the swap that started this chat

  Chat({
    this.id,
    required this.participants,
    required this.participant1Id,
    required this.participant1Name,
    required this.participant2Id,
    required this.participant2Name,
    this.lastMessage = '',
    required this.lastMessageTime,
    required this.createdAt,
    required this.swapRequestId,
  });

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'participant1Id': participant1Id,
      'participant1Name': participant1Name,
      'participant2Id': participant2Id,
      'participant2Name': participant2Name,
      'lastMessage': lastMessage,
      // For new chats, we store a timestamp object
      'lastMessageTime': lastMessageTime, 
      'createdAt': createdAt,
      'swapRequestId': swapRequestId,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json, String id) {
    // Helper function to handle both String (legacy) and Timestamp (new)
    DateTime _parseTimestamp(dynamic timeData) {
      if (timeData is String) {
        return DateTime.parse(timeData);
      }
      if (timeData is Timestamp) {
        return timeData.toDate();
      }
      // Fallback for null or unexpected data
      return DateTime.now(); 
    }

    return Chat(
      id: id,
      participants: List<String>.from(json['participants'] as List),
      participant1Id: json['participant1Id'] as String,
      participant1Name: json['participant1Name'] as String,
      participant2Id: json['participant2Id'] as String,
      participant2Name: json['participant2Name'] as String,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: _parseTimestamp(json['lastMessageTime']), // <--- UPDATED
      createdAt: _parseTimestamp(json['createdAt']), // <--- UPDATED
      swapRequestId: json['swapRequestId'] as String,
    );
  }
}

class Message {
  final String? id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  Message({
    this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp), // <--- UPDATED: Using Firestore Timestamp
    };
  }

  factory Message.fromJson(Map<String, dynamic> json, String id) {
    // Ensure we parse the Firestore Timestamp correctly
    DateTime _parseTimestamp(dynamic timeData) {
      if (timeData is Timestamp) {
        return timeData.toDate();
      }
      // Fallback for unexpected data
      return DateTime.now(); 
    }
    
    return Message(
      id: id,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      text: json['text'] as String,
      timestamp: _parseTimestamp(json['timestamp']), // <--- UPDATED
    );
  }
}