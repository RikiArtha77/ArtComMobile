class Artwork {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String userName;
  final String categoryName;

  Artwork({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.userName,
    required this.categoryName,
  });

  factory Artwork.fromJson(Map<String, dynamic> json, String baseUrl) {
    return Artwork(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: '$baseUrl${json['image_path']}',
      userName: json['user']?['name'] ?? 'Unknown',
      categoryName: json['category']?['name'] ?? 'Unknown',
    );
  }
}
