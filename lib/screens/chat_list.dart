import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:event_planning_app/constants/colors.dart';
import 'package:event_planning_app/container/custom_headertext.dart';
import 'package:event_planning_app/model/database.dart';
import 'package:event_planning_app/screens/chatscreen.dart';
import 'package:event_planning_app/screens/search_screen.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  final String userId;
  const ChatListScreen({super.key, required this.userId});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Document> chats = [];
  Map<String, String> userNames = {};

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  Future<void> fetchChats() async {
    final fetchedChats = await getUserChats(widget.userId);

    Set<String> otherUserIds = {};
    for (var chat in fetchedChats) {
      final data = chat.data as Map<String, dynamic>;
      final participants = List<String>.from(data['participants'] ?? []);
      final otherUserId = getReceiverId(participants, widget.userId);
      if (otherUserId.isNotEmpty) {
        otherUserIds.add(otherUserId);
      }
    }

    final fetchedNames = await fetchUserNames(otherUserIds);

    setState(() {
      chats = List<Document>.from(fetchedChats);
      userNames = fetchedNames;
    });
  }

  Future<Map<String, String>> fetchUserNames(Set<String> userIds) async {
    Map<String, String> names = {};

    for (String userId in userIds) {
      try {
        final result = await databases.listDocuments(
          databaseId: databaseId,
          collectionId: '68053ef6000aac4ae43b',
          queries: [Query.equal('userId', userId)],
        );

        if (result.documents.isNotEmpty) {
          final userDoc = result.documents.first;
          final userData = userDoc.data;
          names[userId] = userData['name'] ?? 'Unknown';
        } else {
          names[userId] = 'Unknown';
        }
      } catch (e) {
        names[userId] = 'Unknown';
      }
    }

    return names;
  }

  String getReceiverId(List<dynamic> participants, String currentUserId) {
    return participants.firstWhere((id) => id != currentUserId,
        orElse: () => '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const CustomHeadText(text: 'Chats')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kLavender,
        child: const Icon(Icons.message, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserSearchScreen(currentUserId: widget.userId),
            ),
          );
        },
      ),
      body: chats.isEmpty
          ? const Center(
              child: Text('No chats yet', style: TextStyle(color: kLavender)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final data = chat.data;

                final lastMessage = data['lastMessage'] ?? 'No messages yet';
                final participants =
                    List<String>.from(data['participants'] ?? []);
                final otherUserId = getReceiverId(participants, widget.userId);
                final otherUserName = userNames[otherUserId] ?? otherUserId;

                return ListTile(
                  title:
                      Text(otherUserName, style: const TextStyle(color: kLavender)),
                  subtitle: Text(
                    '$lastMessage',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessageScreen(
                          chatId: chat.$id,
                          currentUserId: widget.userId,
                          otherUserId: otherUserId,
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
