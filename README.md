# BookSwap - Student Textbook Exchange App

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)

## Overview

BookSwap is a comprehensive mobile application designed for students to exchange textbooks efficiently. Built with Flutter and Firebase, it provides real-time synchronization, secure authentication, and seamless user experience.

### Key Features

- **Firebase Authentication** with email verification
- **Complete CRUD** operations for book listings
- **Real-time Swap System** with state management
- **Live Chat** between users
- **Responsive UI** with modern design
- **Image Upload** for book covers
- **Real-time Updates** across all devices

## Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

lib/
├── data/                    # Data layer
│   └── repositories/        # Firebase repository implementations
│       ├── auth_repository.dart
│       ├── book_repository.dart
│       ├── swap_repository.dart
│       ├── chat_repository.dart
│       └── storage_repository.dart
├── domain/                  # Domain layer
│   └── models/             # Data models
│       ├── user_model.dart
│       ├── book_model.dart
│       ├── swap_model.dart
│       └── chat_model.dart
├── presentation/           # Presentation layer
│   ├── providers/          # State management (Provider pattern)
│   │   ├── auth_provider.dart
│   │   ├── book_provider.dart
│   │   ├── swap_provider.dart
│   │   └── chat_provider.dart
│   └── screens/            # UI screens
│       ├── auth/           # Authentication screens
│       ├── home/           # Main app screens
│       └── chat/           # Chat screens
└── main.dart              # App entry point

## Firebase Setup

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase project created at [Firebase Console](https://console.firebase.google.com/)
- Android/iOS development environment configured

### Configuration Steps

1. **Install FlutterFire CLI**:

   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase**:

   ```bash
   flutterfire configure
   ```

   Select your Firebase project and platforms (Android, iOS, Web).

3. **Firebase Services Required**:
   - **Authentication**: Email/Password authentication
   - **Firestore**: Real-time database
   - **Storage**: Image storage for book covers

4. **Firestore Rules**:
   Add these rules to your Firestore database:

   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users collection
       match /users/{userId} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Listings collection
       match /listings/{listingId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update, delete: if request.auth != null && 
           request.auth.uid == resource.data.ownerId;
       }
       
       // Swaps collection
       match /swaps/{swapId} {
         allow read: if request.auth != null && 
           (request.auth.uid == resource.data.senderId || 
            request.auth.uid == resource.data.recipientId);
         allow create: if request.auth != null;
         allow update: if request.auth != null && 
           (request.auth.uid == resource.data.senderId || 
            request.auth.uid == resource.data.recipientId);
       }
       
       // Chats collection
       match /chats/{chatId} {
         allow read: if request.auth != null && 
           request.auth.uid in resource.data.participants;
         allow create, update: if request.auth != null;
         
         match /messages/{messageId} {
           allow read, write: if request.auth != null;
         }
       }
     }
   }
   ```

5. **Storage Rules**:
   Add these rules to Firebase Storage:

   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /book_covers/{bookId}.jpg {
         allow read: if true;
         allow write: if request.auth != null;
       }
     }
   }
   ```

## Installation

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd BookSwap
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Run the app**:

   ```bash
   flutter run
   ```

## Features

### Authentication

- Email/Password sign up and sign in
- Email verification required before login
- User profile management
- Secure logout

### Book Listings

- Create new book listings with:
  - Book title and author
  - Swap preference
  - Condition (New, Like New, Good, Used)
  - Cover image upload
- Browse all active listings in real-time
- View/edit/delete your own listings
- Real-time updates across all devices

### Swap Functionality

- Initiate swap offers
- Track swap status (Active, Pending, Accepted, Rejected)
- Automatic status updates
- Real-time synchronization

### Chat

- Real-time messaging after swap offers
- Chat history
- Message timestamps

### Settings

- Notification preferences toggle
- Email updates toggle
- Profile information display
- Logout functionality

## Database Schema

### Collections Structure

#### Users

users/{userId}

- uid: string
- email: string
- name: string
- university: string
- profileImageUrl: string (optional)
- createdAt: timestamp

#### Listings

listings/{listingId}

- ownerId: string
- ownerName: string
- ownerEmail: string
- title: string
- author: string
- swapFor: string
- condition: string
- coverImageUrl: string (optional)
- status: string (Active, Pending, Accepted, Rejected)
- createdAt: timestamp
- updatedAt: timestamp

#### Swaps

swaps/{swapId}

- bookOfferedId: string
- bookRequestedId: string
- senderId: string
- senderName: string
- recipientId: string
- recipientName: string
- state: string (Pending, Accepted, Rejected)
- timestamp: timestamp
- respondedAt: timestamp (optional)

#### Chats

chats/{chatId}

- participants: string[]
- participant1Id: string
- participant1Name: string
- participant2Id: string
- participant2Name: string
- lastMessage: string
- lastMessageTime: timestamp
- createdAt: timestamp
- swapRequestId: string
  
  /messages/{messageId}
  - chatId: string
  - senderId: string
  - senderName: string
  - text: string
  - timestamp: timestamp

## State Management

This project uses the **Provider** pattern for state management, providing:

- Centralized authentication state
- Reactive data streams from Firestore
- Real-time UI updates
- Efficient rebuild optimization

## Screens

1. **Welcome Screen**: Entry point with Sign In/Sign Up options
2. **Browse Listings**: Main feed of all available books
3. **My Listings**: User's posted books with edit/delete
4. **Post Book**: Form to create new listings
5. **Chats**: List of conversations
6. **Chat Detail**: Individual chat interface
7. **Settings**: User preferences and profile

## Running the App

**Important**: This app must run on a **physical device or emulator**. Browser-only apps will not be graded.

```bash
# Check connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

## Testing

Run the analyzer to ensure zero warnings:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Important Notes

### Email Verification

- Users **cannot log in** until their email is verified
- Verification email is sent automatically upon signup
- Users must click the verification link before accessing the app

### Real-Time Updates

- All data streams use Firestore's `StreamBuilder` or equivalent
- Changes are synchronized instantly across all devices
- No manual refresh required

### Error Handling

- Firebase integration logs errors for debugging
- User-friendly error messages displayed via SnackBars
- Loading states managed throughout the app

## Security

- Firebase Authentication for secure user management
- Firestore security rules enforce data access
- Only authenticated users can post/listings
- Users can only edit/delete their own listings
- Chat access restricted to participants

## Assignment Requirements Checklist

- ✅ Firebase Authentication (email/password) with email verification
- ✅ User profile stored in Firestore
- ✅ Book listings CRUD operations
- ✅ Firebase Storage for cover images
- ✅ Real-time listings display with StreamBuilder
- ✅ Swap functionality with state management
- ✅ Status tracking (Active, Pending, Accepted, Rejected)
- ✅ Real-time chat after swap offers
- ✅ BottomNavigationBar with 4 screens
- ✅ Settings screen with toggles and profile
- ✅ Provider pattern for state management
- ✅ Clean architecture structure

## Contributing

This is an educational project for demonstration purposes.

## License

This project is for educational use only.

## Author

Leroy M. Carew
Built as part of a Full-Stack Mobile Development assignment.

---

**Note**: Make sure to:

1. Configure Firebase before running the app
2. Set up Firestore security rules
3. Configure Storage rules
4. Run `flutter pub get` after cloning
5. Ensure all dependencies are installed
