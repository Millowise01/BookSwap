class BookListing {
  final String? id;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String title;
  final String author;
  final String swapFor;
  final String condition;
  final String? coverImageUrl;
  final String status; // 'Active', 'Pending', 'Accepted', 'Rejected'
  final DateTime createdAt;
  final DateTime? updatedAt;

  BookListing({
    this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.title,
    required this.author,
    required this.swapFor,
    required this.condition,
    this.coverImageUrl,
    this.status = 'Active',
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'title': title,
      'author': author,
      'swapFor': swapFor,
      'condition': condition,
      'coverImageUrl': coverImageUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory BookListing.fromJson(Map<String, dynamic> json, String id) {
    return BookListing(
      id: id,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      ownerEmail: json['ownerEmail'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      swapFor: json['swapFor'] as String,
      condition: json['condition'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      status: json['status'] as String? ?? 'Active',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  BookListing copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? ownerEmail,
    String? title,
    String? author,
    String? swapFor,
    String? condition,
    String? coverImageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookListing(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      title: title ?? this.title,
      author: author ?? this.author,
      swapFor: swapFor ?? this.swapFor,
      condition: condition ?? this.condition,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

