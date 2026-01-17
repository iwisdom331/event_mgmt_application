import 'package:event_planning_app/saved_data.dart';
import 'package:event_planning_app/screens/check_sessions.dart';
import 'package:event_planning_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SavedData.init();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  // String? token = await messaging.getToken();

  // if (token != null) {
  //   // Store this `token` as needed
  //   print("FCM Token: $token");
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Planning Application',
      theme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const CheckSessions(),
    );
  }
}

Future checkSessions() async {
  try {
    await account.getSession(sessionId: 'current');
    return true;
  } catch (e) {
    return false;
  }
}
