import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/post.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final User user;
  final List<Post> userPosts;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.user,
    required this.userPosts,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    // Filter hanya post yang punya imageUrl valid
    final validPosts = userPosts
        .where((p) => p.imageUrl != null && p.imageUrl!.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: Column(
        children: [
          const SizedBox(height: 24),

          // Foto profil
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                user.profilePictureUrl != null &&
                    user.profilePictureUrl!.isNotEmpty
                ? NetworkImage(user.profilePictureUrl!)
                : null,
            child:
                (user.profilePictureUrl == null ||
                    user.profilePictureUrl!.isEmpty)
                ? const Icon(Icons.person, size: 50)
                : null,
          ),

          const SizedBox(height: 12),

          // Nama
          Text(
            user.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          // Bio
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              user.bio?.isNotEmpty == true ? user.bio! : 'Tidak ada bio',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),

          const SizedBox(height: 12),

          // Tombol Kirim Pesan atau Edit Profil
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(isCurrentUser ? Icons.edit : Icons.message_outlined),
                label: Text(isCurrentUser ? 'Edit Profil' : 'Kirim Pesan'),
                onPressed: () {
                  if (isCurrentUser) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                          name: user.name,
                          email: user.email ?? '',
                          bio: user.bio ?? '',
                          isGoogleAuthEnabled: user.isGoogleAuthEnabled,
                          userId: user.id,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          receiverId: user.id,
                          receiverName: user.name,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Arsip Gambar
          Expanded(
            child: validPosts.isEmpty
                ? const Center(child: Text("Belum ada postingan bergambar"))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: validPosts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (context, index) {
                      final post = validPosts[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
