import '../config.dart';

class User {
  final int id;
  final String name;
  final String? email;
  final String? bio;
  final String? profilePictureUrl;
  final bool isGoogleAuthEnabled;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.profilePictureUrl,
    required this.isGoogleAuthEnabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'] ?? '',
      isGoogleAuthEnabled: json['is_google_auth_enabled'] ?? false,
      profilePictureUrl: json['profile_picture_url'] ?? '',
    );
  }
}
