import 'package:event_planning_app/constants/colors.dart';
// import 'package:event_planning_app/firebase_services.dart/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

double _userRating = 0.0;
// final FirestoreService fireStoreService = FirestoreService();
TextEditingController _commentController = TextEditingController();

Widget buildRatingForm(String vendorId) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Rate this provider",
          style: TextStyle(fontWeight: FontWeight.bold)),
      RatingBar.builder(
        initialRating: 0,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemBuilder: (context, _) =>
            const Icon(Icons.star_rounded, color: kLavender),
        onRatingUpdate: (rating) {
          _userRating = rating;
        },
      ),
      const SizedBox(height: 10),
      TextField(
        style: const TextStyle(color: Colors.white),
        controller: _commentController,
        decoration: const InputDecoration(
            labelText: 'Leave a comment',
            prefixIcon: Icon(Icons.star_border_outlined)),
      ),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: () {
          if (_userRating > 0) {
            // fireStoreService.addRating(
            //   vendorId,
            //   _userRating,
            //   _commentController.text,
            //   DateTime.now(),
            // );
            _commentController.clear();
            _userRating = 0.0;
          } else {
            return;
          }
        },
        child: const Text("Submit"),
      ),
    ],
  );
}
