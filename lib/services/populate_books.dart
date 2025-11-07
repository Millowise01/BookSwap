import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/models/book_model.dart';

class PopulateBooksService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addSampleBooks() async {
    final books = [
      BookListing(
        ownerId: 'user1',
        ownerName: 'Sarah Chen',
        ownerEmail: 'sarah.chen@university.edu',
        title: 'Introduction to Algorithms',
        author: 'Thomas H. Cormen',
        swapFor: 'Data Structures textbook',
        condition: 'Like New',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      BookListing(
        ownerId: 'user2',
        ownerName: 'Marcus Rodriguez',
        ownerEmail: 'marcus.r@university.edu',
        title: 'Calculus: Early Transcendentals',
        author: 'James Stewart',
        swapFor: 'Linear Algebra textbook',
        condition: 'Good',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BookListing(
        ownerId: 'user3',
        ownerName: 'Emily Johnson',
        ownerEmail: 'emily.j@university.edu',
        title: 'Campbell Biology',
        author: 'Jane B. Reece',
        swapFor: 'Chemistry textbook',
        condition: 'Used',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      BookListing(
        ownerId: 'user4',
        ownerName: 'David Kim',
        ownerEmail: 'david.kim@university.edu',
        title: 'Physics for Scientists and Engineers',
        author: 'Raymond A. Serway',
        swapFor: 'Engineering textbook',
        condition: 'New',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      BookListing(
        ownerId: 'user5',
        ownerName: 'Lisa Wang',
        ownerEmail: 'lisa.wang@university.edu',
        title: 'Organic Chemistry',
        author: 'Paula Yurkanis Bruice',
        swapFor: 'Biochemistry textbook',
        condition: 'Like New',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      BookListing(
        ownerId: 'user6',
        ownerName: 'Alex Thompson',
        ownerEmail: 'alex.t@university.edu',
        title: 'Microeconomics',
        author: 'Robert Pindyck',
        swapFor: 'Macroeconomics textbook',
        condition: 'Good',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      BookListing(
        ownerId: 'user7',
        ownerName: 'Jessica Brown',
        ownerEmail: 'jessica.b@university.edu',
        title: 'Psychology: The Science of Mind and Behaviour',
        author: 'Michael W. Passer',
        swapFor: 'Sociology textbook',
        condition: 'Used',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      BookListing(
        ownerId: 'user8',
        ownerName: 'Ryan Martinez',
        ownerEmail: 'ryan.m@university.edu',
        title: 'Fundamentals of Database Systems',
        author: 'Ramez Elmasri',
        swapFor: 'Software Engineering textbook',
        condition: 'Like New',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      BookListing(
        ownerId: 'user9',
        ownerName: 'Amanda Davis',
        ownerEmail: 'amanda.d@university.edu',
        title: 'Discrete Mathematics and Its Applications',
        author: 'Kenneth H. Rosen',
        swapFor: 'Statistics textbook',
        condition: 'Good',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      BookListing(
        ownerId: 'user10',
        ownerName: 'Michael Chang',
        ownerEmail: 'michael.c@university.edu',
        title: 'Operating System Concepts',
        author: 'Abraham Silberschatz',
        swapFor: 'Computer Networks textbook',
        condition: 'New',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];

    try {
      for (final book in books) {
        await _firestore.collection('listings').add(book.toJson());
        print('Added book: ${book.title}');
      }
      print('Successfully added ${books.length} books to Firestore!');
    } catch (e) {
      print('Error adding books: $e');
    }
  }
}