import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget phone;
  final Widget tablet;

  const ResponsiveBuilder({super.key, required this.phone, required this.tablet});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 600 ? tablet : phone;
  }
}
