import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/swap_model.dart';

class SwapRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create swap request
  Future<String> createSwapRequest(SwapRequest swap) async {
    try {
      // Check if book is still available
      final bookDoc = await _firestore.collection('listings').doc(swap.bookRequestedId).get();
      if (!bookDoc.exists || bookDoc.data()?['status'] != 'Active') {
        throw Exception('Book is no longer available for swap');
      }

      // Create swap document
      final docRef = await _firestore.collection('swaps').add(swap.toJson());
      
      // Update the requested book status to 'Pending'
      await _firestore.collection('listings').doc(swap.bookRequestedId).update({
        'status': 'Pending',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get swap requests sent by user
  Stream<List<SwapRequest>> getSwapRequestsSent(String userId) {
    return _firestore
        .collection('swaps')
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .handleError((error) => print('Error getting sent swaps: $error'))
        .map((snapshot) {
      try {
        final swaps = snapshot.docs
            .map((doc) => SwapRequest.fromJson(doc.data(), doc.id))
            .toList();
        swaps.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return swaps;
      } catch (e) {
        print('Error parsing sent swaps: $e');
        return <SwapRequest>[];
      }
    });
  }

  // Get swap requests received by user
  Stream<List<SwapRequest>> getSwapRequestsReceived(String userId) {
    return _firestore
        .collection('swaps')
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .handleError((error) => print('Error getting received swaps: $error'))
        .map((snapshot) {
      try {
        final swaps = snapshot.docs
            .map((doc) => SwapRequest.fromJson(doc.data(), doc.id))
            .toList();
        swaps.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return swaps;
      } catch (e) {
        print('Error parsing received swaps: $e');
        return <SwapRequest>[];
      }
    });
  }

  // Accept swap request
  Future<void> acceptSwapRequest(String swapId, String bookRequestedId, String bookOfferedId) async {
    try {
      final batch = _firestore.batch();

      // Update swap status to Accepted
      final swapRef = _firestore.collection('swaps').doc(swapId);
      batch.update(swapRef, {
        'state': 'Accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Update both book listings to Accepted
      final requestedBookRef = _firestore.collection('listings').doc(bookRequestedId);
      batch.update(requestedBookRef, {
        'status': 'Accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final offeredBookRef = _firestore.collection('listings').doc(bookOfferedId);
      batch.update(offeredBookRef, {
        'status': 'Accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Reject other pending swaps for these books
      await _rejectOtherPendingSwaps(swapId, bookRequestedId, bookOfferedId);
    } catch (e) {
      rethrow;
    }
  }

  // Reject swap request
  Future<void> rejectSwapRequest(String swapId, String bookRequestedId) async {
    try {
      final batch = _firestore.batch();

      // Update swap status to Rejected
      final swapRef = _firestore.collection('swaps').doc(swapId);
      batch.update(swapRef, {
        'state': 'Rejected',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Update book listing back to Active
      final bookRef = _firestore.collection('listings').doc(bookRequestedId);
      batch.update(bookRef, {
        'status': 'Active',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // Get swap by ID
  Future<SwapRequest?> getSwapRequest(String swapId) async {
    try {
      final doc = await _firestore.collection('swaps').doc(swapId).get();
      if (doc.exists) {
        return SwapRequest.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Reject other pending swaps for the same books
  Future<void> _rejectOtherPendingSwaps(String acceptedSwapId, String bookRequestedId, String bookOfferedId) async {
    try {
      // Find other pending swaps involving these books
      final pendingSwaps = await _firestore
          .collection('swaps')
          .where('state', isEqualTo: 'Pending')
          .get();

      final batch = _firestore.batch();
      
      for (final doc in pendingSwaps.docs) {
        if (doc.id != acceptedSwapId) {
          final data = doc.data();
          if (data['bookRequestedId'] == bookRequestedId || 
              data['bookOfferedId'] == bookOfferedId ||
              data['bookRequestedId'] == bookOfferedId ||
              data['bookOfferedId'] == bookRequestedId) {
            batch.update(doc.reference, {
              'state': 'Rejected',
              'respondedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
      
      await batch.commit();
    } catch (e) {
      print('Error rejecting other pending swaps: $e');
    }
  }
}

