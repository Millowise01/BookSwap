import 'package:flutter/material.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/models/chat_model.dart';

class ChatProvider with ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();

  final List<Chat> _chats = [];
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Stream user's chats
  Stream<List<Chat>> getUserChats(String userId) {
    return _chatRepository.getUserChats(userId);
  }

  // Stream chat messages
  Stream<List<Message>> getChatMessages(String chatId) {
    return _chatRepository.getChatMessages(chatId);
  }

  Future<bool> createChat({
    required List<String> participants,
    required String participant1Id,
    required String participant1Name,
    required String participant2Id,
    required String participant2Name,
    required String swapRequestId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final chat = Chat(
        participants: participants,
        participant1Id: participant1Id,
        participant1Name: participant1Name,
        participant2Id: participant2Id,
        participant2Name: participant2Name,
        lastMessageTime: DateTime.now(),
        createdAt: DateTime.now(),
        swapRequestId: swapRequestId,
      );

      await _chatRepository.createChat(chat);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final message = Message(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        timestamp: DateTime.now(),
      );

      await _chatRepository.sendMessage(message);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Chat?> getChatBySwapRequest(String swapRequestId) async {
    return await _chatRepository.getChatBySwapRequest(swapRequestId);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

