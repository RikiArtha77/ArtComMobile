import '../config.dart';

class User {
  final int id;
  final String name;
  final String? email;
  final String? bio;
  final String? profilePicture;
  final bool isGoogleAuthEnabled;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.bio,
    this.profilePicture,
    required this.isGoogleAuthEnabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'],
      profilePicture: json['profile_picture'],
      isGoogleAuthEnabled: json['is_google_auth_enabled'] ?? false,
    );
  }
  String get profilePictureUrl =>
      profilePicture != null ? '$baseUrl/storage/$profilePicture' : '';
}
