import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload book cover image
  Future<String?> uploadBookCover(String bookId, File imageFile) async {
    try {
      final ref = _storage.ref().child('book_covers/$bookId.jpg');
      
      if (kIsWeb) {
        // For web, read file as bytes
        final bytes = await imageFile.readAsBytes();
        await ref.putData(bytes);
      } else {
        // For mobile, use putFile
        await ref.putFile(imageFile);
      }
      
      return await ref.getDownloadURL();
    } catch (e) {
      print('Storage upload error: $e');
      return null; // Return null if upload fails
    }
  }

  // Delete book cover image
  Future<void> deleteBookCover(String bookId) async {
    try {
      final ref = _storage.ref().child('book_covers/$bookId.jpg');
      await ref.delete();
    } catch (e) {
      print('Storage delete error: $e');
      // Ignore delete errors for now
    }
  }
}