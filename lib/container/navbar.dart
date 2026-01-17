// ignore_for_file: prefer_const_constructors

import 'package:event_planning_app/constants/colors.dart';
import 'package:event_planning_app/saved_data.dart';
import 'package:event_planning_app/screens/chat_list.dart';
import 'package:event_planning_app/screens/homescreen.dart';
import 'package:event_planning_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNav extends StatefulWidget {
  final int initialIndex;
  const BottomNav({super.key, this.initialIndex = 0});
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ChatListScreen(
      userId: SavedData.getUserId(),
    ),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadLastIndex();
  }

  Future<void> _loadLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentIndex = prefs.getInt('last_index') ?? 0;
    });
  }

  Future<void> _saveIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_index', index);
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    _saveIndex(index); // Save index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: appBarColor,
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
