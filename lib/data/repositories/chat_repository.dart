import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create chat
  Future<String> createChat(Chat chat) async {
    try {
      final docRef = await _firestore.collection('chats').add(chat.toJson());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get user's chats
  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .handleError((error) => print('Error getting chats: $error'))
        .map((snapshot) {
      try {
        final chats = snapshot.docs
            .map((doc) => Chat.fromJson(doc.data(), doc.id))
            .toList();
        chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
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

  // Get chat messages
  Stream<List<Message>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .snapshots()
        .handleError((error) => print('Error getting messages: $error'))
        .map((snapshot) {
      try {
        final messages = snapshot.docs
            .map((doc) => Message.fromJson(doc.data(), doc.id))
            .toList();
        messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return messages;
      } catch (e) {
        print('Error parsing messages: $e');
        return <Message>[];
      }
    });
  }

  // Send message
  Future<void> sendMessage(Message message) async {
    try {
      // Add message to chat's messages subcollection
      await _firestore
          .collection('chats')
          .doc(message.chatId)
          .collection('messages')
          .add(message.toJson());

      // Update chat's last message
      await _firestore.collection('chats').doc(message.chatId).update({
        'lastMessage': message.text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
