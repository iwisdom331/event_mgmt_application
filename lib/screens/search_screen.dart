import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:event_planning_app/model/database.dart';
import 'package:event_planning_app/screens/chatscreen.dart';
import 'package:flutter/material.dart';

class UserSearchScreen extends StatefulWidget {
  final String currentUserId;
  const UserSearchScreen({super.key, required this.currentUserId});

  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Document> _results = [];
  bool isLoading = false;

  Future<void> searchUsers(String keyword) async {
    setState(() => isLoading = true);

    try {
      if (keyword.trim().isEmpty) {
        setState(() {
          _results = [];
          isLoading = false;
        });
        return;
      }

      final res = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: '68053ef6000aac4ae43b',
        queries: [
          Query.search('name', keyword),
          Query.notEqual('userId', widget.currentUserId),
        ],
      );

      setState(() => _results = res.documents);
      print("Found ${res.documents.length} users");
    } catch (e) {
      print("Search error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> startChatWithUser(
      String otherUserId, String otherUserName) async {
    final chatId = await getOrCreateChat([
      widget.currentUserId,
      otherUserId,
      otherUserName,
    ]);

    if (chatId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MessageScreen(
            chatId: chatId,
            currentUserId: widget.currentUserId,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to start chat. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start New Chat')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (val) {
                if (val.trim().length >= 2) searchUsers(val.trim());
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final user = _results[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title: Text(
                        user.data['name'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () => startChatWithUser(
                        user.data['userId'],
                        user.data['name'],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
