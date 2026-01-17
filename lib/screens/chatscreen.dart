import 'package:event_planning_app/constants/colors.dart';
import 'package:event_planning_app/model/database.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserId;
  final String? otherUserName;

  const MessageScreen({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
    this.otherUserName,
  });

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    final fetchedMessages = await getMessagesForChat(widget.chatId);
    setState(() {
      messages = fetchedMessages;
    });
  }

  Future<void> handleSend() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    final timestamp = DateTime.now().toIso8601String();
    await sendMessageToUser(
      widget.chatId,
      timestamp,
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      message: message,
    );
    _controller.clear();
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          widget.otherUserName ?? 'Chat',
          style: const TextStyle(
            color: kLavender,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMine = msg.data['senderId'] == widget.currentUserId;
                return Align(
                  alignment:
                      isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(msg.data['message']),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: handleSend,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
