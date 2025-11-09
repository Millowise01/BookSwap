class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? university;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.university,
    this.profileImageUrl,
  });

  // Convert to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'university': university,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create model from Firestore JSON data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      university: json['university'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  // Utility to create a new instance with optional changed values
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? university,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      university: university ?? this.university,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}