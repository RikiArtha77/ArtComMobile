import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';
import 'dart:convert';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  List conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final res = await ApiService().get(
      '/conversations',
      headers: {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        conversations = data;
      });
    } else {
      debugPrint('Error loading conversations: ${res.statusCode}');
      debugPrint('Body: ${res.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Percakapan')),
      body: conversations.isEmpty
          ? const Center(child: Text('Belum ada percakapan.'))
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final c = conversations[index];
                final partnerName = c['partner_name']?.toString() ?? 'Tidak diketahui';
                final lastMessage = c['last_message']?.toString() ?? '';
                final unreadCount = c['unread_count'] ?? 0;

                return ListTile(
                  title: Text(partnerName),
                  subtitle: Text(lastMessage),
                  trailing: unreadCount > 0
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          userId: c['conversation_id'],
                          partnerName: partnerName,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
