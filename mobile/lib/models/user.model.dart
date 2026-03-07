class User {
  final int id;
  final String username;
  final String? profileImage;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    this.profileImage,
    this.createdAt,
  });

  String get profileImageUrl {
    if (profileImage != null && !profileImage!.startsWith('http')) {
      return 'http://192.168.100.122:8000/storage/$profileImage';
    }
    return profileImage ?? 'https://ui-avatars.com/api/?name=$username&background=06B6D4&color=fff';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      profileImage: json['profile_image'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
