import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'add_artwork_screen.dart';
import '../widgets/artwork_grid.dart';
import '../widgets/featured_slider.dart';
import 'chat_list_screen.dart';
import '../services/user_service.dart';
import '../models/user.dart';
import '../models/post.dart';
import 'user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _refreshData() async {
    setState(() {}); // Trigger rebuild
  }

  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  void _searchUser(String query, String token) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    final service = UserService(token);
    try {
      final results = await service.searchUsers(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      print('Search error: $e');
    }
  }

  void _showSearchDialog(String token) {
    _searchController.clear();
    _searchResults.clear();
    _hasSearched = false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cari Pengguna'),
        content: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Masukkan nama...'),
          onSubmitted: (query) {
            Navigator.pop(context);
            _searchUser(query, token);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _searchUser(_searchController.text, token);
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  void _onAddArtwork(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddArtworkScreen()),
    ).then((_) => _refreshData());
  }

  Future<void> _openUserProfile(
    User u,
    bool isCurrentUser,
    String token,
  ) async {
    final posts = await UserService(token).getUserPosts(u.id);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          user: u,
          userPosts: posts,
          isCurrentUser: isCurrentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.user;
    final token = auth.token ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Art Gallery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(token),
          ),
          if (user != null)
            GestureDetector(
              onTap: () => _openUserProfile(user, true, token),
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[300],
                  child: ClipOval(
                    child:
                        user.profilePictureUrl != null &&
                            user.profilePictureUrl!.isNotEmpty
                        ? Image.network(
                            user.profilePictureUrl!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person, size: 20),
                          )
                        : const Icon(Icons.person, size: 20),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isNotEmpty
          ? ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final u = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: u.profilePictureUrl != null
                        ? NetworkImage(u.profilePictureUrl!)
                        : null,
                    child: u.profilePictureUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(u.name),
                  subtitle: Text(u.bio ?? '-'),
                  onTap: () => _openUserProfile(u, user?.id == u.id, token),
                );
              },
            )
          : _hasSearched
          ? const Center(child: Text('Tidak ada pengguna ditemukan.'))
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Featured Works",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FeaturedSlider(),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Explore More",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ArtworkGrid(),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddArtwork(context),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'Home',
              onPressed: () {
                setState(() {
                  _searchResults.clear();
                  _isSearching = false;
                  _hasSearched = false;
                  _searchController.clear();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.message_outlined),
              tooltip: 'Messages',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatListScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
