import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved; // <-- Added onSaved

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onSaved, // <-- Added onSaved
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style:
          const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      onSaved: onSaved, // <-- Added here
    );
  }
}
