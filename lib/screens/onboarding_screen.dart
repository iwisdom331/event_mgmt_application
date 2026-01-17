import 'dart:ui';

import 'package:flutter/material.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/event_image.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 7.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          const Center(
            child: Text(
              'SMARTEVENT',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
              height: 20), // Optional spacing between image and indicator
        ],
      ),
    );
  }
}
