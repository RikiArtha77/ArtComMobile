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
    this.email,
    this.bio,
    this.profilePictureUrl,
    required this.isGoogleAuthEnabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rawProfilePicture = json['profile_picture_url']?.toString().trim();

    return User(
      id: json['id'],
      name: json['name'] ?? 'Tanpa Nama',
      email: json['email'],
      bio: (json['bio'] != null && json['bio'].toString().trim().isNotEmpty)
          ? json['bio']
          : null,
      profilePictureUrl:
          (rawProfilePicture != null && rawProfilePicture.isNotEmpty)
          ? (rawProfilePicture.startsWith('http')
                ? rawProfilePicture
                : '$baseImageUrl/$rawProfilePicture')
          : null,
      isGoogleAuthEnabled:
          json['is_google_auth_enabled'] == true ||
          json['is_google_auth_enabled'] == 1,
    );
  }
}
