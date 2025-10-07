import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String username;
  final String? imageUrl;
  final DateTime? createdAt;

  const ChatBubble({
    super.key,
    required this.isMe,
    required this.message,
    required this.username,
    this.imageUrl,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? Colors.blue[700] : Colors.grey[300];
    final textColor = isMe ? Colors.white : Colors.black87;
    final screenWidth = MediaQuery.of(context).size.width;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe && imageUrl != null) ...[
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(imageUrl!),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: isMe
                              ? const Radius.circular(12)
                              : const Radius.circular(0),
                          bottomRight: isMe
                              ? const Radius.circular(0)
                              : const Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        message,
                        style: TextStyle(color: textColor, fontSize: 15),
                      ),
                    ),
                  ),
                  if (createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatTime(createdAt!),
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ),
                ],
              ),
            ),
            if (isMe && imageUrl != null) ...[
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(imageUrl!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}
