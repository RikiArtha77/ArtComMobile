import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../models/message.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Message> _conversations = [];
  bool _isLoading = true;
  late ChatService chatService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthService>(context, listen: false);
      final token = auth.token;

      if (token != null) {
        chatService = ChatService(token);
        _loadConversations();
      } else {
        print("Token tidak ditemukan. Pastikan user sudah login.");
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _loadConversations() async {
    try {
      final data = await chatService.getConversations();
      setState(() {
        _conversations = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Gagal memuat percakapan: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Percakapan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
          ? const Center(child: Text('Belum ada percakapan'))
          : ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final message = _conversations[index];
                final user = message.otherUser;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user?.profilePictureUrl != null
                        ? NetworkImage(user!.profilePictureUrl!)
                        : null,
                    child: user?.profilePictureUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(user?.name ?? 'Pengguna'),
                  subtitle: message.body != null
                      ? Text(message.body!)
                      : const Text('Gambar terkirim'),
                  onTap: () {
                    if (user != null) {
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
                );
              },
            ),
    );
  }
}
