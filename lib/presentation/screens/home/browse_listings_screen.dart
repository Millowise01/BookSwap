import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/chat_provider.dart';
import '../../../domain/models/book_model.dart';
import 'post_book_screen.dart';

class BrowseListingsScreen extends StatelessWidget {
  const BrowseListingsScreen({super.key});

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
      appBar: AppBar(
        title: const Text('Browse Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostBookScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<BookListing>>(
        stream: bookProvider.getAllListings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              final isOwner = listing.ownerId == userId;
              final canSwap = !isOwner && listing.status == 'Active';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: InkWell(
                  onTap: () {
                    // Could navigate to detail screen
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover Image
                      if (listing.coverImageUrl != null)
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(listing.coverImageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.book,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                      
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    listing.title,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(listing.status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    listing.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'by ${listing.author}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.swap_horiz, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Swap for: ${listing.swapFor}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.check_circle, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Condition: ${listing.condition}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (!isOwner)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: canSwap
                                      ? () => _showSwapDialog(context, listing, userId)
                                      : null,
                                  child: const Text('Swap'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.blue;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
