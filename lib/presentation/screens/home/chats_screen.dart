import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../../domain/models/chat_model.dart';

import '../chat/chat_detail_screen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final userId = authProvider.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatDialog(context, userId),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Chat>>(
        stream: chatProvider.getUserChats(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start swapping to begin chatting!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherPersonName = chat.participant1Id == userId
                  ? chat.participant2Name
                  : chat.participant1Name;

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(otherPersonName),
                subtitle: Text(
                  chat.lastMessage.isNotEmpty
                      ? chat.lastMessage
                      : 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formatTime(chat.lastMessageTime),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        chatId: chat.id!,
                        otherUserName: otherPersonName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showNewChatDialog(BuildContext context, String userId) {
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the email of the person you want to chat with:'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                Navigator.pop(context);
                await _createManualChat(context, userId, email);
              }
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

  Future<void> _createManualChat(BuildContext context, String userId, String email) async {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
      
      // Create a simple chat ID based on email
      final otherUserId = 'user_${email.hashCode.abs()}';
      
      final success = await chatProvider.createChat(
        participants: [userId, otherUserId],
        participant1Id: userId,
        participant1Name: authProvider.userProfile?.name ?? 'You',
        participant2Id: otherUserId,
        participant2Name: email.split('@')[0], // Use email prefix as name
        swapRequestId: 'manual_chat',
      );
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

