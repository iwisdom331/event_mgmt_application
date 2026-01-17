import 'package:appwrite/models.dart';
import 'package:event_planning_app/constants/colors.dart';
import 'package:event_planning_app/container/custom_headertext.dart';
import 'package:event_planning_app/container/event_container.dart';
import 'package:event_planning_app/model/database.dart';
import 'package:event_planning_app/screens/create_event.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Document> events = [];

  @override
  void initState() {
    getAllEvents().then((value) {
      events = value;
      setState(() {});
    });
    super.initState();
  }

  void refresh() {
    getAllEvents().then((value) {
      events = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: const CustomHeadText(text: 'Home'),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Create Event',
          shape: const CircleBorder(),
          backgroundColor: kLavender,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateEvent()),
            ).then((value) {
              refresh();
            });
          },
          child: const Icon(Icons.add, color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Explore events around you !',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: kLavender,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                    ),
                    child: CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(
                          child: Center(child: Column(children: [])),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => EventContainer(
                              data: events[index],
                            ),
                            childCount: events.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
