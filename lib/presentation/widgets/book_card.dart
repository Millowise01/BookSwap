import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/book_model.dart';

class BookCard extends StatelessWidget {
  final BookListing listing;
  final bool isOwner;
  final bool canSwap;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.listing,
    this.isOwner = false,
    this.canSwap = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image - Added AspectRatio for consistent book shape
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio( // Ensure consistent book ratio (3:4 is standard)
                    aspectRatio: 3 / 4,
                    child: _buildBookCover(),
                  ),
                ),
              ),
            ),
            
            // Book Info, Metadata, and Action Button
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title and Author
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          listing.author,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    
                    const Spacer(), // Pushes content towards the bottom

                    // Metadata Row: Condition and Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Condition Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getConditionColor(listing.condition),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            listing.condition,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        // Time ago
                        Text(
                          _getTimeAgo(listing.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Action Button (Conditional based on role)
                    _buildActionButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a contextual action button
  Widget _buildActionButton(BuildContext context) {
    if (isOwner) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            // Placeholder for Edit action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit feature clicked.')),
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.blue),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Edit Listing', style: TextStyle(fontSize: 12)),
        ),
      );
    } else if (canSwap) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // Placeholder for Swap action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Swap request sent.')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
          ),
          icon: const Icon(Icons.swap_horiz, size: 16),
          label: const Text('Request Swap', style: TextStyle(fontSize: 12)),
        ),
      );
    }

    // Default state if no action is available
    return const Center(
      child: Text(
        'Details Only',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }


  // Helper method for the book cover (Unchanged)
  Widget _buildBookCover() {
    if (listing.coverImageUrl == null || listing.coverImageUrl!.isEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[300],
        child: const Icon(
          Icons.book,
          size: 50,
          color: Colors.grey,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: listing.coverImageUrl!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 40,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              'Image\nUnavailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for condition color (Updated slightly)
  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'New':
        return Colors.green;
      case 'Like New':
        return Colors.blue;
      case 'Good':
        return Colors.orange;
      case 'Used':
      case 'Fair': // Added 'Fair' for robustness
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  // Helper method for time ago (Improved granularity)
  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago'; // Weeks
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago'; // Days
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago'; // Hours
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago'; // Minutes
    } else {
      return 'Now';
    }
  }
}