// import 'package:flutter/material.dart';
// import '../models/user.dart';
// import 'chat_screen.dart';

// class UserProfileScreen extends StatelessWidget {
//   final User user;

//   const UserProfileScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(user.name)),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             CircleAvatar(
//               radius: 50,
//               backgroundImage: user.profilePictureUrl != null
//                   ? NetworkImage(user.profilePictureUrl!)
//                   : null,
//               child: user.profilePictureUrl == null
//                   ? const Icon(Icons.person, size: 50)
//                   : null,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               user.name,
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Text(user.bio ?? '-', style: const TextStyle(fontSize: 16)),
//             const Spacer(),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.message),
//               label: const Text("Kirim Pesan"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ChatScreen(receiverId: user.id),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
