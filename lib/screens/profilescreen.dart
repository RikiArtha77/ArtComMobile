// import 'package:flutter/material.dart';
// import '../models/user.dart';
// import '../models/post.dart';
// import 'chat_screen.dart';

// class OtherUserProfileScreen extends StatelessWidget {
//   final User user;
//   final List<Post> userPosts;
//   final bool isCurrentUser;

//   const OtherUserProfileScreen({
//     super.key,
//     required this.user,
//     required this.userPosts,
//     this.isCurrentUser = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(user.name)),
//       body: Column(
//         children: [
//           const SizedBox(height: 24),
//           // Foto Profil
//           CircleAvatar(
//             radius: 50,
//             backgroundImage: user.profilePictureUrl != null
//                 ? NetworkImage(user.profilePictureUrl!)
//                 : null,
//             child: user.profilePictureUrl == null
//                 ? const Icon(Icons.person, size: 50)
//                 : null,
//           ),
//           const SizedBox(height: 12),

//           // Nama
//           Text(
//             user.name,
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),

//           // Bio
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//             child: Text(
//               user.bio ?? 'Tidak ada bio',
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 16, color: Colors.black87),
//             ),
//           ),

//           // Tombol
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: Icon(isCurrentUser ? Icons.edit : Icons.message_outlined),
//                 label: Text(isCurrentUser ? 'Edit Profil' : 'Kirim Pesan'),
//                 onPressed: () {
//                   if (isCurrentUser) {
//                     // Navigasi ke EditProfileScreen
//                   } else {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ChatScreen(receiverId: user.id),
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Grid Postingan
//           Expanded(
//             child: userPosts.isEmpty
//                 ? const Center(child: Text("Belum ada postingan"))
//                 : GridView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     itemCount: userPosts.length,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3,
//                       crossAxisSpacing: 8,
//                       mainAxisSpacing: 8,
//                     ),
//                     itemBuilder: (context, index) {
//                       final post = userPosts[index];
//                       return ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           post.imageUrl,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => Container(
//                             color: Colors.grey[300],
//                             child: const Icon(Icons.broken_image),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
