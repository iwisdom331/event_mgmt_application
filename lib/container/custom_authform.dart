// import 'package:event_planning_app/constants/helper.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AuthTextFormField extends StatefulWidget {
//   final IconData? icon;
//   final String label;
//   final String hint;
//   final String hintText;
//   final bool isPassword;
//   final TextInputType? keyboardType;
//   final int? maxLines;
//   final VoidCallback? onTap;
//   final bool? readOnly;
//   final String? Function(String?) validator;
//   final TextEditingController? controller;
//   final void Function(String?)? onSaved;

//   const AuthTextFormField({
//     super.key,
//     required this.hintText,
//     this.isPassword = true,
//     this.keyboardType,
//     required this.validator,
//     this.controller,
//     this.onSaved,
//     this.icon,
//     required this.label,
//     required this.hint,
//     this.maxLines,
//     this.onTap,
//     this.readOnly,
//   });

//   @override
//   State<AuthTextFormField> createState() => _AuthFormState();
// }

// class _AuthFormState extends State<AuthTextFormField> {
//   late bool hidePassword;

//   @override
//   void initState() {
//     hidePassword = widget.isPassword;
//     super.initState();
//   }

//   void _toggleVisibility() {
//     setState(() {
//       hidePassword = !hidePassword;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.only(left: 15, right: 17),
//         height: Helper.getHeight(480, context),
//         width: Helper.getWidth(359, context),
//         margin: EdgeInsets.symmetric(vertical: Helper.getHeight(12, context)),
//         child: TextFormField(
//           style: GoogleFonts.inter(
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//             color: const Color(0xFFDCC8BE),
//           ),
//           obscureText: widget.isPassword ? hidePassword : false,
//           validator: widget.validator,
//           controller: widget.controller,
//           onSaved: widget.onSaved,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: const Color(0xffFEFDFB),
//             hintText: widget.hintText,
//             hintStyle: GoogleFonts.poppins(
//               fontWeight: FontWeight.w400,
//               color: const Color(0xffA8A7A7),
//               fontSize: 12,
//             ),
//             labelText: widget.label,
//             labelStyle: const TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.w600,
//             ),
//             prefixIcon: widget.isPassword
//                 ? GestureDetector(
//                     onTap: _toggleVisibility,
//                     child: Icon(
//                       hidePassword ? Icons.visibility_off : Icons.visibility,
//                       size: 20,
//                       color: const Color(0xffA8A7A7),
//                     ),
//                   )
//                 : null,
//             contentPadding:
//                 const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(
//                 color: Color(0xffEAEAF5),
//                 width: 1.0,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(
//                 color: Colors.white,
//                 width: 1.5,
//               ),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: const BorderSide(
//                 color: Color(0xffEAEAF5),
//                 width: 1.0,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
