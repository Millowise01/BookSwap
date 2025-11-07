class BookCoverService {
  static String getCoverUrl(String title, String author) {
    // Using Open Library Covers API for real book covers
    final cleanTitle = title.replaceAll(' ', '+').toLowerCase();
    final cleanAuthor = author.replaceAll(' ', '+').toLowerCase();
    
    // Generate a consistent cover based on title
    final covers = {
      'introduction to algorithms': 'https://covers.openlibrary.org/b/isbn/9780262033848-L.jpg',
      'clean code': 'https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg',
      'design patterns': 'https://covers.openlibrary.org/b/isbn/9780201633610-L.jpg',
      'calculus: early transcendentals': 'https://covers.openlibrary.org/b/isbn/9781285741550-L.jpg',
      'operating system concepts': 'https://covers.openlibrary.org/b/isbn/9781118063330-L.jpg',
      'database system concepts': 'https://covers.openlibrary.org/b/isbn/9780073523323-L.jpg',
      'computer networks': 'https://covers.openlibrary.org/b/isbn/9780132126953-L.jpg',
      'artificial intelligence': 'https://covers.openlibrary.org/b/isbn/9780136042594-L.jpg',
      'linear algebra and its applications': 'https://covers.openlibrary.org/b/isbn/9780321982384-L.jpg',
      'discrete mathematics': 'https://covers.openlibrary.org/b/isbn/9780073383095-L.jpg',
      'data structures & algorithms': 'https://covers.openlibrary.org/b/isbn/9780132847377-L.jpg',
      'javascript: the definitive guide': 'https://covers.openlibrary.org/b/isbn/9781491952023-L.jpg',
      'python crash course': 'https://covers.openlibrary.org/b/isbn/9781593279288-L.jpg',
      'the pragmatic programmer': 'https://covers.openlibrary.org/b/isbn/9780135957059-L.jpg',
      'introduction to statistical learning': 'https://covers.openlibrary.org/b/isbn/9781461471370-L.jpg',
    };
    
    final key = title.toLowerCase();
    return covers[key] ?? _generatePlaceholderCover(title, author);
  }
  
  static String _generatePlaceholderCover(String title, String author) {
    // Generate a colored placeholder with title and author
    final colors = ['FF6B6B', '4ECDC4', '45B7D1', 'FFA07A', '98D8C8', 'F7DC6F', 'BB8FCE', '85C1E9'];
    final colorIndex = title.length % colors.length;
    final color = colors[colorIndex];
    
    final encodedTitle = Uri.encodeComponent(title.length > 20 ? title.substring(0, 20) + '...' : title);
    final encodedAuthor = Uri.encodeComponent(author.length > 15 ? author.substring(0, 15) + '...' : author);
    
    return 'https://via.placeholder.com/300x400/$color/FFFFFF?text=$encodedTitle%0A%0A$encodedAuthor';
  }
}