import '../services/api_service.dart';

class User {
  final int id;
  final String username;
  final String? email;
  final String? profileImage;
  final bool isFriend;
  final bool requestSent;
  final bool requestReceived;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    this.email,
    this.profileImage,
    this.isFriend = false,
    this.requestSent = false,
    this.requestReceived = false,
    this.createdAt,
  });

  String get profileImageUrl {
    if (profileImage != null && !profileImage!.startsWith('http')) {
      return '${ApiService.storageUrl}/$profileImage';
    }
    return profileImage ?? 'https://ui-avatars.com/api/?name=$username&background=06B6D4&color=fff';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profileImage: json['profile_image'],
      isFriend: json['is_friend'] ?? false,
      requestSent: json['request_sent'] ?? false,
      requestReceived: json['request_received'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile_image': profileImage,
      'is_friend': isFriend,
      'request_sent': requestSent,
      'request_received': requestReceived,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
