import '../domain/models/book_model.dart';
import '../domain/models/swap_model.dart';
import '../domain/models/chat_model.dart';

class MockDataService {
  static List<BookListing> getMockListings() {
    return [
      BookListing(
        id: 'mock1',
        ownerId: 'user1',
        ownerName: 'Sarah Chen',
        ownerEmail: 'sarah.chen@university.edu',
        title: 'Introduction to Algorithms',
        author: 'Thomas H. Cormen',
        swapFor: 'Data Structures textbook',
        condition: 'Like New',
        status: 'Active',
        coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/41T0iBxY8FL._SX440_BO1,204,203,200_.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      BookListing(
        id: 'mock2',
        ownerId: 'user2',
        ownerName: 'Marcus Rodriguez',
        ownerEmail: 'marcus.r@university.edu',
        title: 'Calculus: Early Transcendentals',
        author: 'James Stewart',
        swapFor: 'Linear Algebra textbook',
        condition: 'Good',
        status: 'Active',
        coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51H9zKJP8qL._SX389_BO1,204,203,200_.jpg',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BookListing(
        id: 'mock3',
        ownerId: 'user3',
        ownerName: 'Emily Johnson',
        ownerEmail: 'emily.j@university.edu',
        title: 'Campbell Biology',
        author: 'Jane B. Reece',
        swapFor: 'Chemistry textbook',
        condition: 'Used',
        status: 'Active',
        coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51Kq8eFiOuL._SX389_BO1,204,203,200_.jpg',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      BookListing(
        id: 'mock4',
        ownerId: 'user4',
        ownerName: 'David Kim',
        ownerEmail: 'david.kim@university.edu',
        title: 'Physics for Scientists and Engineers',
        author: 'Raymond A. Serway',
        swapFor: 'Engineering textbook',
        condition: 'New',
        status: 'Active',
        coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51xKVEKs7HL._SX389_BO1,204,203,200_.jpg',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      BookListing(
        id: 'mock5',
        ownerId: 'user5',
        ownerName: 'Lisa Wang',
        ownerEmail: 'lisa.wang@university.edu',
        title: 'Organic Chemistry',
        author: 'Paula Yurkanis Bruice',
        swapFor: 'Biochemistry textbook',
        condition: 'Like New',
        status: 'Active',
        coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51rQb-TgzJL._SX389_BO1,204,203,200_.jpg',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      BookListing(
        id: 'mock6',
        ownerId: 'user6',
        ownerName: 'Alex Thompson',
        ownerEmail: 'alex.t@university.edu',
        title: 'Microeconomics',
        author: 'Robert Pindyck',
        swapFor: 'Macroeconomics textbook',
        condition: 'Good',
        status: 'Active',
        coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51Kq8eFiOuL._SX389_BO1,204,203,200_.jpg',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      BookListing(
        id: 'mock7',
        ownerId: 'user7',
        ownerName: 'Jessica Brown',
        ownerEmail: 'jessica.b@university.edu',
        title: 'Psychology: The Science of Mind and Behaviour',
        author: 'Michael W. Passer',
        swapFor: 'Sociology textbook',
        condition: 'Used',
        status: 'Active',
        coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51xKVEKs7HL._SX389_BO1,204,203,200_.jpg',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      BookListing(
        id: 'mock8',
        ownerId: 'user8',
        ownerName: 'Ryan Martinez',
        ownerEmail: 'ryan.m@university.edu',
        title: 'Fundamentals of Database Systems',
        author: 'Ramez Elmasri',
        swapFor: 'Software Engineering textbook',
        condition: 'Like New',
        status: 'Active',
        coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/41T0iBxY8FL._SX440_BO1,204,203,200_.jpg',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  static List<SwapRequest> getMockSwapRequests() {
    return [
      SwapRequest(
        id: 'swap1',
        bookOfferedId: 'mock1',
        bookRequestedId: 'mock2',
        senderId: 'user1',
        senderName: 'John Doe',
        recipientId: 'user2',
        recipientName: 'Jane Smith',
        state: 'Pending',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  static List<Chat> getMockChats() {
    return [
      Chat(
        id: 'chat1',
        participants: ['user1', 'user2'],
        participant1Id: 'user1',
        participant1Name: 'John Doe',
        participant2Id: 'user2',
        participant2Name: 'Jane Smith',
        lastMessage: 'Hi, is the book still available?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        swapRequestId: 'swap1',
      ),
    ];
  }
}