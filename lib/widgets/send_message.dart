import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SendMessage extends StatefulWidget {
  final String otherUser;
  const SendMessage({super.key, required this.otherUser});

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  final _messageController = TextEditingController();
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit() async {
    final message = _messageController.text;
    if (message.trim().isEmpty) {
      //do nothink
      return;
    }

    try {
      FocusScope.of(context).unfocus();
      _messageController.clear();
      //send data to the server and reload chat_message
      final supaBase = Supabase.instance;
      final User user = supaBase.client.auth.currentUser!;
      final userRow = await supaBase.client
          .from("users")
          .select()
          .eq('user_id', user.id)
          .single();
       await supaBase.client.from('messages').insert({
        "userId": user.id,
        "username": userRow['username'],
        "imageUrl": userRow['imageUrl'],
        'message': message,
        'toUser': widget.otherUser,
        
      });

     
    } catch (e) {
      print("❌ $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: "send message..."),
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
            ),
          ),
          IconButton(
            onPressed: _submit,
            icon: Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
