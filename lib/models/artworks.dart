class Artwork {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String userName;
  final String userProfileUrl;
  final String categoryName;

  Artwork({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.userName,
    required this.userProfileUrl,
    required this.categoryName,
  });

  factory Artwork.fromJson(Map<String, dynamic> json, String baseUrl) {
    return Artwork(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: '$baseUrl${json['image_path']}',
      userName: json['user']?['name'] ?? 'Unknown',
      userProfileUrl: json['user']?['profile_picture'] != null
          ? '$baseUrl${json['user']['profile_picture']}'
          : 'https://via.placeholder.com/150', // fallback jika tidak ada foto
      categoryName: json['category']?['name'] ?? 'Unknown',
    );
  }
}
