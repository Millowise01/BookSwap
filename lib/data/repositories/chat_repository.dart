import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/chat_model.dart'; // Assuming this is the correct path

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create chat
  Future<String> createChat(Chat chat) async {
    try {
      final chatData = chat.toJson();
      // Ensure time fields are Firestore Timestamps on creation
      chatData['lastMessageTime'] = Timestamp.fromDate(chat.lastMessageTime);
      chatData['createdAt'] = Timestamp.fromDate(chat.createdAt);

      final docRef = await _firestore.collection('chats').add(chatData);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get user's chats (real-time stream)
  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true) // <--- ADDED: Ordering by time
        .snapshots()
        .handleError((error) => print('Error getting chats: $error'))
        .map((snapshot) {
      try {
        final chats = snapshot.docs
            .map((doc) => Chat.fromJson(doc.data(), doc.id))
            .toList();
        // Sorting is now primarily done by Firestore, but keeping for safety if needed
        return chats; 
      } catch (e) {
        print('Error parsing chats: $e');
        return <Chat>[];
      }
    });
  }

  // Get chat by swap request
  Future<Chat?> getChatBySwapRequest(String swapRequestId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('swapRequestId', isEqualTo: swapRequestId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Chat.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get chat by ID
  Future<Chat?> getChat(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists) {
        return Chat.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get chat messages (real-time stream)
  Stream<List<Message>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // <--- ADDED: Server-side sorting
        .snapshots()
        .handleError((error) => print('Error getting messages: $error'))
        .map((snapshot) {
      try {
        final messages = snapshot.docs
            .map((doc) => Message.fromJson(doc.data(), doc.id))
            .toList();
        // Local sorting removed as it's now handled by Firestore order by
        return messages; 
      } catch (e) {
        print('Error parsing messages: $e');
        return <Message>[];
      }
    });
  }

  // Send message (using Batched Write for atomicity)
  Future<void> sendMessage(Message message) async {
    try {
      final batch = _firestore.batch();
      final chatRef = _firestore.collection('chats').doc(message.chatId);
      final messageRef = chatRef.collection('messages').doc();

      // 1. Add message to chat's messages subcollection
      batch.set(messageRef, message.toJson());

      // 2. Update chat's last message using FieldValue.serverTimestamp() for accuracy
      batch.update(chatRef, {
        'lastMessage': message.text,
        'lastMessageTime': FieldValue.serverTimestamp(), // <--- Using Server Timestamp
      });

      // Commit the batch. This ensures both updates happen together.
      await batch.commit(); 

    } catch (e) {
      rethrow;
    }
  }
}