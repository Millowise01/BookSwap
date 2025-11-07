# BookSwap App - Design Summary

## Database Schema / ERD

### Firestore Collections

```
BookSwap Database
│
├── users
│   └── {userId}
│       ├── uid: string
│       ├── email: string
│       ├── name: string
│       ├── university: string
│       ├── profileImageUrl: string?
│       └── createdAt: timestamp
│
├── listings
│   └── {listingId}
│       ├── ownerId: string
│       ├── ownerName: string
│       ├── ownerEmail: string
│       ├── title: string
│       ├── author: string
│       ├── swapFor: string
│       ├── condition: string
│       ├── coverImageUrl: string?
│       ├── status: string
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp?
│
├── swaps
│   └── {swapId}
│       ├── bookOfferedId: string
│       ├── bookRequestedId: string
│       ├── senderId: string
│       ├── senderName: string
│       ├── recipientId: string
│       ├── recipientName: string
│       ├── state: string
│       ├── timestamp: timestamp
│       └── respondedAt: timestamp?
│
└── chats
    └── {chatId}
        ├── participants: array<string>
        ├── participant1Id: string
        ├── participant1Name: string
        ├── participant2Id: string
        ├── participant2Name: string
        ├── lastMessage: string
        ├── lastMessageTime: timestamp
        ├── createdAt: timestamp
        ├── swapRequestId: string
        │
        └── messages (subcollection)
            └── {messageId}
                ├── chatId: string
                ├── senderId: string
                ├── senderName: string
                ├── text: string
                └── timestamp: timestamp
```

### Firebase Storage Structure

```
/
└── book_covers/
    └── {bookId}.jpg
```

## Swap State Modeling

### State Flow

```
Active → Pending → [Accepted | Rejected]
  ↑          ↓
  └──────────┘ (if rejected)
```

### State Transitions

1. **Active**: Initial state when a book listing is created
   - Book is available for swapping
   - No pending requests

2. **Pending**: When a swap offer is made
   - Triggered by: `createSwapRequest()`
   - Both books involved get status 'Pending'
   - Real-time notification to recipient

3. **Accepted**: When recipient accepts the swap
   - Triggered by: `acceptSwapRequest()`
   - Both books set to 'Accepted'
   - Swap is finalized

4. **Rejected**: When recipient rejects the swap
   - Triggered by: `rejectSwapRequest()`
   - Requested book returns to 'Active'
   - Offered book may remain 'Pending' if other swaps exist

### Implementation Details

**Book Listing Status Updates:**
- Updated atomically via Firestore transactions in `SwapRepository`
- Prevents race conditions
- Ensures data consistency

**Swap Request Management:**
- Separate `swaps` collection tracks requests independently
- Links sender and recipient with book IDs
- Timestamps for chronological ordering

**Real-Time Synchronization:**
- `StreamBuilder` in UI listens to Firestore streams
- Changes propagate instantly to all connected clients
- No manual refresh required

## State Management Implementation

### Provider Pattern

The app uses **Provider** for state management across four key areas:

#### 1. AuthProvider
**Responsibilities:**
- User authentication state
- Email verification checks
- User profile data
- Sign in/out/signup operations

**Key Streams:**
```dart
Stream<User?> authStateChanges
Stream<bool> checkEmailVerification(String uid)
```

**State Fields:**
- `User? _user`
- `UserModel? _userProfile`
- `bool _isLoading`
- `String? _errorMessage`

#### 2. BookProvider
**Responsibilities:**
- Book listing CRUD operations
- Image upload management
- Listings streams for Browse and My Listings

**Key Streams:**
```dart
Stream<List<BookListing>> getAllListings()
Stream<List<BookListing>> getMyListings(String userId)
```

**Operations:**
- `createBookListing()` - Create with optional image
- `updateBookListing()` - Update details/image
- `deleteBookListing()` - Remove listing

#### 3. SwapProvider
**Responsibilities:**
- Swap request creation
- Accept/reject operations
- Swap state management

**Key Streams:**
```dart
Stream<List<SwapRequest>> getSentRequests(String userId)
Stream<List<SwapRequest>> getReceivedRequests(String userId)
```

**Operations:**
- `createSwapRequest()` - Initiate swap
- `acceptSwapRequest()` - Approve swap
- `rejectSwapRequest()` - Decline swap

#### 4. ChatProvider
**Responsibilities:**
- Chat room creation
- Message sending
- Real-time message streams

**Key Streams:**
```dart
Stream<List<Chat>> getUserChats(String userId)
Stream<List<Message>> getChatMessages(String chatId)
```

**Operations:**
- `createChat()` - New conversation
- `sendMessage()` - Post message
- `getChatBySwapRequest()` - Link chat to swap

### Why Provider?

**Advantages:**
1. **Simplicity**: Less boilerplate than Bloc
2. **Built-in**: No additional heavy dependencies
3. **Performance**: Efficient rebuilds with `Consumer` and `Selector`
4. **Reactivity**: Seamless integration with Firestore streams
5. **Learning Curve**: Easier for students to understand

**Alternative Considered**: Riverpod
- More type-safe but steeper learning curve
- Provider chosen for accessibility

## Design Trade-offs & Challenges

### Challenge 1: Email Verification Flow

**Problem:** Users must verify email before accessing app, but Firestore rules are permissive during signup.

**Solution:** 
- Server-side check in `signIn()` method
- Throws exception if email not verified
- Enforces logout if verification missing
- Stream-based verification status checks

**Trade-off:** Slightly slower authentication, but more secure.

### Challenge 2: Swap Status Consistency

**Problem:** Multiple users could initiate swaps on the same book simultaneously.

**Solution:**
- Firestore batch writes ensure atomicity
- Status checked before allowing new swaps
- Transaction-based updates prevent race conditions

**Trade-off:** More complex code, but guarantees data integrity.

### Challenge 3: Chat Creation Timing

**Problem:** When to create chat - immediately on swap offer or after acceptance?

**Solution:**
- Create chat **immediately** after swap offer
- Allows pre-acceptance negotiation
- Linked to swap via `swapRequestId`

**Trade-off:** More chats created, but better UX for negotiation.

### Challenge 4: Image Upload Flow

**Problem:** Large images slow down book creation.

**Solution:**
- Create listing first (synchronous)
- Upload image second (asynchronous)
- Update listing with URL after upload completes
- Graceful degradation if upload fails

**Trade-off:** Two-step process, but listings appear immediately.

### Challenge 5: Real-Time Performance

**Problem:** StreamBuilder rebuilds entire lists on any change.

**Optimizations:**
- Query-level filtering (`where` clauses)
- Ordered queries (indexed fields)
- Subcollections for messages (not flat structure)
- Efficient data models (minimal fields)

**Trade-off:** More Firestore reads, but instant UI updates.

### Architecture Decision: Clean Architecture

**Rationale:**
1. **Separation of Concerns**: Data/Domain/Presentation layers
2. **Testability**: Easy to mock repositories
3. **Maintainability**: Clear file organization
4. **Scalability**: Easy to add features

**Structure:**
```
Data Layer:    Repositories (Firebase implementations)
Domain Layer:  Models (Plain Dart classes)
Presentation:  Providers + Screens (UI logic)
```

**Benefit:** Changes to Firebase API don't affect UI code.

## Security Considerations

### Firestore Security Rules

1. **Authentication Required**: All read/write operations require auth
2. **User-Specific Access**: Users can only modify their own data
3. **Swap Access Control**: Only sender/recipient can view swaps
4. **Chat Participant Verification**: Only participants can access chats

### Storage Security

1. **Authenticated Uploads**: Only logged-in users can upload
2. **Public Reads**: Anyone can view book covers (marketing benefit)
3. **Filename Sanitization**: UUID-based naming prevents collisions

### Data Validation

1. **Client-Side**: Form validation in Flutter
2. **Server-Side**: Firestore rules as second layer
3. **Type Safety**: Strong Dart typing prevents errors

## Performance Optimizations

1. **Lazy Loading**: Images loaded on-demand via URLs
2. **Stream Caching**: Provider caches stream data
3. **Indexed Queries**: Firestore indexes on `ownerId`, `participants`, etc.
4. **Batch Operations**: Multiple writes combined where possible
5. **Efficient Widgets**: `ListView.builder` for large lists

## Future Enhancements

1. **Search/Filter**: Query listings by title, author, course
2. **Notifications**: Push notifications for swap updates
3. **Ratings System**: Rate successful swaps
4. **Book Recommendations**: AI-powered suggestions
5. **Offline Mode**: Local caching with Firestore persistence
6. **Image Compression**: Reduce upload times
7. **Group Swaps**: Multi-party exchanges
8. **Report System**: Flag inappropriate listings

## Testing Strategy

1. **Unit Tests**: Provider logic, model transformations
2. **Integration Tests**: Repository + Firestore interactions
3. **Widget Tests**: UI component rendering
4. **E2E Tests**: Full user flows (signup → swap → chat)

## Deployment Checklist

- [ ] Configure Firebase project
- [ ] Set up Firestore security rules
- [ ] Configure Storage rules
- [ ] Generate signing keys
- [ ] Set up app store listings
- [ ] Configure CI/CD pipeline
- [ ] Performance monitoring
- [ ] Crash reporting

