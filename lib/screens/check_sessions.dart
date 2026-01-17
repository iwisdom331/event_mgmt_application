import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:event_planning_app/container/navbar.dart';
import 'package:event_planning_app/main.dart';
import 'package:event_planning_app/screens/login.dart';
import 'package:flutter/material.dart';

class CheckSessions extends StatefulWidget {
  const CheckSessions({super.key});

  @override
  State<CheckSessions> createState() => _CheckSessionsState();
}

class _CheckSessionsState extends State<CheckSessions> {
  bool isChecking = true;
  bool hasConnection = true;

  @override
  void initState() {
    super.initState();
    _initCheck();
  }

  Future<void> _initCheck() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    hasConnection = connectivityResult != ConnectivityResult.none;

    if (!hasConnection) {
      setState(() {
        isChecking = false;
      });
      return;
    }

    final sessionExists = await checkSessions();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => sessionExists ? const BottomNav() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isChecking
            ? const CircularProgressIndicator()
            : hasConnection
                ? const Text('Checking sessions...')
                : const Text('No internet connection'),
      ),
      backgroundColor: Colors.white,
    );
  }
}
