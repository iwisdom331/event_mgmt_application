import 'package:event_planning_app/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomHeadText extends StatefulWidget {
  final String text;
  const CustomHeadText({super.key, required this.text});

  @override
  State<CustomHeadText> createState() => _CustomHeadTextState();
}

class _CustomHeadTextState extends State<CustomHeadText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      textAlign: TextAlign.start,
      widget.text,
      style: const TextStyle(
          color: kLavender, fontSize: 26, fontWeight: FontWeight.w600),
    );
  }
}
