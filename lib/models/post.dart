import '../config.dart'; // pastikan path config.dart sesuai

class Post {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String? imageUrl;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final String? rawPath = json['image_path'];
    final String? fullUrl = (rawPath != null && rawPath.isNotEmpty)
        ? '$baseUrl$rawPath'
        : null;

    return Post(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      imageUrl: fullUrl,
    );
  }
}
