import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/book_model.dart';

class BookRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create book listing
  Future<String> createBookListing(BookListing book) async {
    try {
      final docRef = await _firestore.collection('listings').add(book.toJson());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get all active listings
  Stream<List<BookListing>> getAllListings() {
    return _firestore
        .collection('listings')
        .snapshots()
        .handleError((error) {
          print('Error getting listings: $error');
        })
        .map((snapshot) {
      try {
        final listings = snapshot.docs
            .map((doc) => BookListing.fromJson(doc.data(), doc.id))
            .toList();
        // Sort in memory to avoid index requirement
        listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return listings;
      } catch (e) {
        print('Error parsing listings: $e');
        return <BookListing>[];
      }
    });
  }

  // Get user's listings
  Stream<List<BookListing>> getUserListings(String userId) {
    return _firestore
        .collection('listings')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .handleError((error) {
          print('Error getting user listings: $error');
        })
        .map((snapshot) {
      try {
        final listings = snapshot.docs
            .map((doc) => BookListing.fromJson(doc.data(), doc.id))
            .toList();
        // Sort in memory to avoid index requirement
        listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return listings;
      } catch (e) {
        print('Error parsing user listings: $e');
        return <BookListing>[];
      }
    });
  }

  // Get single listing
  Future<BookListing?> getListing(String listingId) async {
    try {
      final doc = await _firestore.collection('listings').doc(listingId).get();
      if (doc.exists) {
        return BookListing.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update book listing
  Future<void> updateBookListing(BookListing book) async {
    try {
      await _firestore
          .collection('listings')
          .doc(book.id)
          .update(book.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Update listing status
  Future<void> updateListingStatus(String listingId, String status) async {
    try {
      await _firestore.collection('listings').doc(listingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete book listing
  Future<void> deleteBookListing(String listingId) async {
    try {
      await _firestore.collection('listings').doc(listingId).delete();
    } catch (e) {
      rethrow;
    }
  }
}

