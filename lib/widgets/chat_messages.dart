import 'package:chat_app/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatMessages extends StatefulWidget {
  final String otherUserId;
  const ChatMessages({super.key, required this.otherUserId});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final user = Supabase.instance.client.auth.currentUser!;
  final ScrollController _scrollController = ScrollController();

  // Flag to ensure initial scroll only happens once
  bool _hasInitiallyScrolled = false;

  @override
  void initState() {
    super.initState();
    // No specific initialization needed for auto-scrolling here.
  }

  void _scrollToBottom(int messageCount) {
    if (messageCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: true)
          .map(
            (rows) => rows
                .where(
                  (row) =>
                      (row['userId'] == user.id &&
                          row['toUser'] == widget.otherUserId) ||
                      (row['userId'] == widget.otherUserId &&
                          row['toUser'] == user.id),
                )
                .toList(),
          ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages yet'));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        final loadMessages = snapshot.data!;

        // Trigger initial scroll only once after data is loaded
        if (!_hasInitiallyScrolled) {
          _scrollToBottom(loadMessages.length);
          _hasInitiallyScrolled = true; // Set flag to true after initial scroll
        }

        // Also trigger scroll for new messages arriving
        // This will now always scroll to the bottom when new messages come in
        // and the list rebuilds.
        _scrollToBottom(loadMessages.length);

        return ListView.builder(
          controller: _scrollController,
          itemCount: loadMessages.length,
          itemBuilder: (context, index) {
            return ChatBubble(
              isMe: loadMessages[index]['userId'] == user.id,
              message: loadMessages[index]['message'],
              username: loadMessages[index]['username'],
              createdAt: DateTime.parse(loadMessages[index]['created_at']),
              imageUrl: loadMessages[index]['imageUrl'],
            );
          },
        );
      },
    );
  }
}
