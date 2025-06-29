import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'enable_google_auth_screen.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final bool isGoogleAuthEnabled;
  final int userId;
  final String bio;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.bio,
    required this.isGoogleAuthEnabled,
    required this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _bioController = TextEditingController();
  final _nameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  File? _pickedImage;
  bool _isChangingPassword = false;
  bool _googleAuthEnabled = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _googleAuthEnabled = widget.isGoogleAuthEnabled;
    _bioController.text = widget.bio;
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  void _handleEnableGoogleAuth(BuildContext context) async {
    final success = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnableGoogleAuthScreen(userId: widget.userId),
      ),
    );

    if (success == true) {
      setState(() => _googleAuthEnabled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Authenticator berhasil diaktifkan'),
        ),
      );
    }
  }

  void _handleSaveProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.updateProfile(
      name: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      profilePicture: _pickedImage,
    );

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal memperbarui profil'),
        ),
      );
    }
  }

  void _handleChangePassword(BuildContext context) async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isChangingPassword = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.changePassword(
      currentPassword: _oldPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    setState(() => _isChangingPassword = false);

    if (result['success']) {
      _oldPasswordController.clear();
      _newPasswordController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password berhasil diubah')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal mengubah password')),
      );
    }
  }

  void _handleLogout(BuildContext context) {
    Provider.of<AuthService>(context, listen: false).logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : (user?.profilePictureUrl != null &&
                              user!.profilePictureUrl.isNotEmpty
                          ? NetworkImage(user.profilePictureUrl)
                          : const AssetImage('assets/default_avatar.png')
                                as ImageProvider),
                child:
                    _pickedImage == null &&
                        (user?.profilePictureUrl == null ||
                            user!.profilePictureUrl.isEmpty)
                    ? const Icon(Icons.camera_alt)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Nama wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(labelText: 'Bio'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan Perubahan'),
                    onPressed: () => _handleSaveProfile(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 40),
            ListTile(
              title: const Text('Google Authenticator'),
              subtitle: Text(
                _googleAuthEnabled ? 'Sudah diaktifkan' : 'Belum aktif',
              ),
              trailing: _googleAuthEnabled
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : ElevatedButton(
                      onPressed: () => _handleEnableGoogleAuth(context),
                      child: const Text('Aktifkan'),
                    ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text(
              'Ganti Password',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Form(
              key: _passwordFormKey,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password Lama',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Masukkan password lama'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password Baru',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.length < 8
                        ? 'Password minimal 8 karakter'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _isChangingPassword
                        ? null
                        : () => _handleChangePassword(context),
                    child: _isChangingPassword
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Ganti Password'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}
