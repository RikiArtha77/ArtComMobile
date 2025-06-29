// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'dart:convert';

// class EditProfileScreen extends StatefulWidget {
//   final Map user;
//   final String token;

//   const EditProfileScreen({super.key, required this.user, required this.token});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   late TextEditingController _nameController;
//   late TextEditingController _bioController;
//   File? _imageFile;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     _nameController = TextEditingController(text: widget.user['name']);
//     _bioController = TextEditingController(text: widget.user['bio'] ?? '');
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _bioController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() => _imageFile = File(picked.path));
//     }
//   }

//   Future<void> _submit() async {
//     if (_nameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong')));
//       return;
//     }

//     setState(() => _isLoading = true);

//     final request = http.MultipartRequest(
//       'POST',
//       Uri.parse('http://192.168.1.6:8000/api/profile/update'),
//     );

//     request.headers['Authorization'] = 'Bearer ${widget.token}';
//     request.fields['name'] = _nameController.text.trim();
//     request.fields['bio'] = _bioController.text.trim();

//     if (_imageFile != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath(
//           'profile_picture',
//           _imageFile!.path,
//           contentType: MediaType('image', 'jpeg'),
//         ),
//       );
//     }

//     try {
//       final response = await request.send();
//       final respStr = await response.stream.bytesToString();

//       setState(() => _isLoading = false);

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profil berhasil diperbarui')),
//         );
//         Navigator.pop(context, true);
//       } else {
//         final error = jsonDecode(respStr);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(error['message'] ?? 'Gagal memperbarui profil'),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final profileImageUrl = widget.user['profile_picture_url'] ?? '';

//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Profil')),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           GestureDetector(
//             onTap: _pickImage,
//             child: CircleAvatar(
//               radius: 50,
//               backgroundImage: _imageFile != null
//                   ? FileImage(_imageFile!)
//                   : (profileImageUrl.isNotEmpty
//                             ? NetworkImage(profileImageUrl)
//                             : const AssetImage('assets/default_avatar.png'))
//                         as ImageProvider,
//               child: _imageFile == null && profileImageUrl.isEmpty
//                   ? const Icon(Icons.camera_alt)
//                   : null,
//             ),
//           ),
//           const SizedBox(height: 20),
//           TextField(
//             controller: _nameController,
//             decoration: const InputDecoration(
//               labelText: 'Nama',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           const SizedBox(height: 16),
//           TextField(
//             controller: _bioController,
//             decoration: const InputDecoration(
//               labelText: 'Bio',
//               border: OutlineInputBorder(),
//             ),
//             maxLines: 2,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: _isLoading ? null : _submit,
//             icon: _isLoading
//                 ? const SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : const Icon(Icons.save),
//             label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Perubahan'),
//           ),
//         ],
//       ),
//     );
//   }
// }
