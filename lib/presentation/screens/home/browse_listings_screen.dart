import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/book_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/chat_provider.dart';
// IMPORTANT: Ensure this path is correct for the new file
import '../../widgets/book_card.dart'; 
import '../../../domain/models/book_model.dart';
import 'post_book_screen.dart';
import '../../../services/populate_books.dart'; 
import '../book_details/book_details_screen.dart'; // Assuming you have this screen

class BrowseListingsScreen extends StatefulWidget {
  const BrowseListingsScreen({super.key});

  @override
  State<BrowseListingsScreen> createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> {
  // Removed unused initState

  void _startDirectChat(BuildContext context, BookListing listing, String currentUserId) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await chatProvider.createChat(
        participants: [currentUserId, listing.ownerId],
        participant1Id: currentUserId,
        participant1Name: authProvider.userProfile?.name ?? 'User',
        participant2Id: listing.ownerId,
        participant2Name: listing.ownerName,
        swapRequestId: 'direct_chat',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat started! Go to Chats tab to message.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSwapDialog(BuildContext context, BookListing listing, String currentUserId) async {
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Using .first on a Stream to get a single snapshot (safe way to get current data)
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
                        ? CachedNetworkImage(
                            imageUrl: book.coverImageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                            errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.red),
                          )
                        : const Icon(Icons.book, size: 40),
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
        final swapId = await swapProvider.createSwapRequest(
          bookOfferedId: myBook.id!,
          bookRequestedId: listing.id!,
          senderId: currentUserId,
          senderName: authProvider.userProfile?.name ?? 'User',
          recipientId: listing.ownerId,
          recipientName: listing.ownerName,
        );

        if (swapId != null && context.mounted) {
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
  
  void _showBookDetails(BuildContext context, BookListing listing) {
    Navigator.push(
      context,
      // You should navigate to a dedicated detail screen, not a generic AlertDialog
      MaterialPageRoute(builder: (context) => BookDetailsScreen(listing: listing)),
    );
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    final userId = authProvider.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Listings'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
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
            // Log error to console for debugging
            debugPrint('Browse Listings Stream Error: ${snapshot.error}');
            return Center(child: Text('Error loading listings.'));
          }

          final listings = snapshot.data ?? [];
          
          // Optional: Deduplication check for debugging (remove this block once fixed)
          final uniqueListingIds = listings.map((l) => l.id).toSet();
          if (uniqueListingIds.length != listings.length) {
              debugPrint('Warning: Duplicate listings detected in Firestore data stream.');
          }
          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined, // Changed to outlined for consistency
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
                    onPressed: () async {
                      // Using Future.microtask to avoid triggering warnings in sync context
                      await Future.microtask(() async {
                        await PopulateBooksService.addSampleBooks();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sample books added!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      });
                    },
                    child: const Text('Add Sample Books'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PostBookScreen()),
                      );
                    },
                    child: const Text('Post Your Own Book'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              // Keeping 0.7, but rely on BookCard internal constraints for safety.
              childAspectRatio: 0.7, 
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              final isOwner = listing.ownerId == userId;
              final canSwap = !isOwner && listing.status == 'Active';

              return BookCard(
                listing: listing,
                isOwner: isOwner,
                canSwap: canSwap,
                onTap: () {
                  if (canSwap) {
                    _showSwapDialog(context, listing, userId);
                  } else {
                    // Use the new navigation to a detail screen
                    _showBookDetails(context, listing);
                  }
                },
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
}