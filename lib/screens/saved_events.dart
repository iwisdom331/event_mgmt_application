import 'package:appwrite/models.dart';
import 'package:event_planning_app/constants/colors.dart';
import 'package:event_planning_app/container/custom_headertext.dart';
import 'package:event_planning_app/model/database.dart';
import 'package:event_planning_app/saved_data.dart';
import 'package:event_planning_app/screens/events_details.dart';
import 'package:flutter/material.dart';

class SavedEvent extends StatefulWidget {
  const SavedEvent({super.key});

  @override
  State<SavedEvent> createState() => _SavedEventState();
}

class _SavedEventState extends State<SavedEvent> {
  List<Document> events = [];
  List<Document> userEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() {
    String userId = SavedData.getUserId();
    getAllEvents().then((value) {
      events = value;
      for (var event in events) {
        List<dynamic> participants = event.data["participants"];
        if (participants.contains(userId)) {
          userEvents.add(event);
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: appBarColor,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: CustomHeadText(text: 'RSVP Events'),
        ),
      ),
      body: ListView.builder(
        itemCount: userEvents.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetails(data: userEvents[index]),
                ),
              );
            },
            title: Text(
              userEvents[index].data["name"],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              userEvents[index].data["location"],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            trailing: const Icon(
              Icons.check_circle,
              color: kLavender,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
