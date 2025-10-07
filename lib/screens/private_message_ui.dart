// import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/send_message.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance;

class PrivateMessageUi extends StatelessWidget {
  final String otherUserId;
  final String imageUrl;
  final String username;
  PrivateMessageUi({
    super.key,
    required this.otherUserId,
    required this.imageUrl,
    required this.username,
  });

  final user = _supabase.client.auth.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: imageUrl,
              child: CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(username),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: ChatMessages(otherUserId: otherUserId)),
          SendMessage(otherUser: otherUserId),
        ],
      ),
    );
  }
}
