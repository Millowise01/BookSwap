import 'package:flutter/material.dart';
import '../../data/repositories/swap_repository.dart';
import '../../domain/models/swap_model.dart';

class SwapProvider with ChangeNotifier {
  final SwapRepository _swapRepository = SwapRepository();

  final List<SwapRequest> _sentRequests = [];
  final List<SwapRequest> _receivedRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SwapRequest> get sentRequests => _sentRequests;
  List<SwapRequest> get receivedRequests => _receivedRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Stream sent requests
  Stream<List<SwapRequest>> getSentRequests(String userId) {
    return _swapRepository.getSwapRequestsSent(userId);
  }

  // Stream received requests
  Stream<List<SwapRequest>> getReceivedRequests(String userId) {
    return _swapRepository.getSwapRequestsReceived(userId);
  }

  Future<String?> createSwapRequest({
    required String bookOfferedId,
    required String bookRequestedId,
    required String senderId,
    required String senderName,
    required String recipientId,
    required String recipientName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final swapRequest = SwapRequest(
        bookOfferedId: bookOfferedId,
        bookRequestedId: bookRequestedId,
        senderId: senderId,
        senderName: senderName,
        recipientId: recipientId,
        recipientName: recipientName,
        timestamp: DateTime.now(),
      );

      final swapId = await _swapRepository.createSwapRequest(swapRequest);
      _isLoading = false;
      notifyListeners();
      return swapId;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> acceptSwapRequest({
    required String swapId,
    required String bookRequestedId,
    required String bookOfferedId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _swapRepository.acceptSwapRequest(
        swapId,
        bookRequestedId,
        bookOfferedId,
      );
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

  Future<bool> rejectSwapRequest({
    required String swapId,
    required String bookRequestedId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _swapRepository.rejectSwapRequest(swapId, bookRequestedId);
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

