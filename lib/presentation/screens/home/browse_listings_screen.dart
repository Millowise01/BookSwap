import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/chat_provider.dart';
import '../../../domain/models/book_model.dart';
import 'post_book_screen.dart';

class BrowseListingsScreen extends StatefulWidget {
  const BrowseListingsScreen({super.key});

  @override
  State<BrowseListingsScreen> createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _showSwapDialog(BuildContext context, BookListing listing, String currentUserId) async {
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Get user's active listings
    final myListings = await bookProvider.getMyListings(currentUserId).first;
    
    if (myListings.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to post a book first before you can swap!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      final myBook = await showDialog<BookListing>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Book to Swap'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: myListings.length,
              itemBuilder: (context, index) {
                final book = myListings[index];
                return Card(
                  child: ListTile(
                    leading: book.coverImageUrl != null
                        ? Image.network(
                            book.coverImageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.book),
                    title: Text(book.title),
                    subtitle: Text(book.author),
                    onTap: () => Navigator.pop(context, book),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (myBook != null && context.mounted) {
        // Create swap request
        final swapId = await swapProvider.createSwapRequest(
          bookOfferedId: myBook.id!,
          bookRequestedId: listing.id!,
          senderId: currentUserId,
          senderName: authProvider.userProfile?.name ?? 'User',
          recipientId: listing.ownerId,
          recipientName: listing.ownerName,
        );

        if (swapId != null && context.mounted) {
          // Create chat with swap request ID
          await chatProvider.createChat(
            participants: [currentUserId, listing.ownerId],
            participant1Id: currentUserId,
            participant1Name: authProvider.userProfile?.name ?? 'User',
            participant2Id: listing.ownerId,
            participant2Name: listing.ownerName,
            swapRequestId: swapId,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Swap offer sent!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else if (context.mounted) {
          String errorMsg = swapProvider.errorMessage ?? 'Failed to send swap offer';
          if (errorMsg.contains('no longer available')) {
            errorMsg = 'This book is no longer available for swap';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    final userId = authProvider.user?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Browse Listings'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<BookListing>>(
        stream: bookProvider.getAllListings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading books...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final listings = snapshot.data ?? [];
          
          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No listings yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to post a book!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PostBookScreen()),
                      );
                    },
                    child: const Text('Post Your First Book'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              final isOwner = listing.ownerId == userId;
              final canSwap = !isOwner && listing.status == 'Active';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (canSwap) {
                      _showSwapDialog(context, listing, userId);
                    } else {
                      _showBookDetails(context, listing);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Book Cover
                        Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: listing.coverImageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(listing.coverImageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            color: listing.coverImageUrl == null
                                ? Colors.grey[600]
                                : null,
                          ),
                          child: listing.coverImageUrl == null
                              ? const Icon(
                                  Icons.book,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        
                        // Book Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'By ${listing.author}',
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getConditionColor(listing.condition),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  listing.condition,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Time and Chat Icon
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getTimeAgo(listing.createdAt),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostBookScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBookDetails(BuildContext context, BookListing listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(listing.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.coverImageUrl != null)
              Center(
                child: Image.network(
                  listing.coverImageUrl!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text('Author: ${listing.author}'),
            const SizedBox(height: 8),
            Text('Condition: ${listing.condition}'),
            const SizedBox(height: 8),
            Text('Swap for: ${listing.swapFor}'),
            const SizedBox(height: 8),
            Text('Owner: ${listing.ownerName}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'New':
        return Colors.green;
      case 'Like New':
        return Colors.blue;
      case 'Good':
        return Colors.orange;
      case 'Used':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getTimeAgo(DateTime? createdAt) {
    if (createdAt == null) return 'Recently';
    
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Recently';
    }
  }
}
