import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'add_artwork_screen.dart';
import '../widgets/artwork_grid.dart';
import '../widgets/featured_slider.dart';
import 'message_list_screen.dart';
import 'profile_screen.dart';
import './OTPInputScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _refreshData() async {
    setState(() {
    });
  }

  void _onAddArtwork(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddArtworkScreen()),
    ).then((_) => _refreshData());
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Art Gallery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          GestureDetector(
            onTap: () {
              Navigator.push( 
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    name: user?.name ?? '',
                    email: user?.email ?? '',
                    bio: user?.bio ?? '',
                    isGoogleAuthEnabled: user?.isGoogleAuthEnabled ?? false,
                    userId: user?.id ?? 0,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: (user != null && user.profilePicture != null)
                    ? NetworkImage(user.profilePictureUrl)
                    : const AssetImage('assets/default_avatar.png')
                          as ImageProvider,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Featured Works",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                FeaturedSlider(),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Explore More",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                ArtworkGrid(),
              ],
            ),
          ),
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
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.message_outlined),
              tooltip: 'Messages',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MessageListScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
