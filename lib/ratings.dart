import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rating_dialog/rating_dialog.dart';

void showRatingDialog(BuildContext context, recoID, username) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return RatingDialog(
        initialRating: 1.0,
        title: const Text('Rate This Location', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,),
        ),
        message: const Text('Tap a star to set your rating.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
        image: const Icon(Icons.rate_review, size: 100, color: Colors.amber,),
        submitButtonText: 'Submit',
        onCancelled: () {

        },
        enableComment: false,
        onSubmitted: (response) async {
          showDialog(
              context: context,
              barrierDismissible: false, // Prevents dismissing the dialog by tapping outside
              builder: (context) {
                return AlertDialog(
                  title: const Text('Thank You!'),
                  content: const Text('Thank you for your feedback.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the thank you dialog
                        Navigator.of(context).pop(); // Close the rating dialog
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              }
          );
          //print('rating: ${response.rating}, comment: ${response.comment}');
          // Initialize Firestore
          FirebaseFirestore firestore = FirebaseFirestore.instance;

          // Find existing document with the same user and recoID
          QuerySnapshot existingDocs = await firestore
              .collection('ratings')
              .where('user', isEqualTo: username)
              .where('recoID', isEqualTo: recoID)
              .get();

          if (existingDocs.docs.isNotEmpty) {
            // Update the existing document fields without overwriting 'ratingID'
            firestore.collection('ratings').doc(existingDocs.docs.first.id).set({
              'rating': response.rating,
            }, SetOptions(merge: true));

          } else {
            // Add a new document if no existing document is found
            DocumentReference docRef = await firestore.collection('ratings').add({
              'rating': response.rating,
              'user': username,
              'recoID': recoID,
            });

            String ratingID = docRef.id;
            await docRef.update({'ratingID': ratingID});
          }

        },
      );
    },
  );
}

Future<Map<String, dynamic>> getRatingInfo(String recoID) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    QuerySnapshot querySnapshot = await firestore
        .collection('ratings')
        .where('recoID', isEqualTo: recoID)
        .get();

    if (querySnapshot.size > 0) {
      double totalRating = 0.0;
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        totalRating += doc['rating'];
      }

      double calculatedRating = totalRating / querySnapshot.size;
      calculatedRating = double.parse(calculatedRating.toStringAsFixed(2)); // Truncate to 2 decimal places
      int numberOfRatings = querySnapshot.size;

      return {'calculatedRating': calculatedRating, 'numberOfRatings': numberOfRatings};
    } else {
      return {'calculatedRating': 0.0, 'numberOfRatings': 0}; // Default values if no ratings are found
    }
  } catch (error) {
    print("Error getting rating info: $error");
    return {'calculatedRating': 0.0, 'numberOfRatings': 0};
  }
}


Widget buildRatingInfoWidget(String recoID) {
  return FutureBuilder<Map<String, dynamic>>(
    future: getRatingInfo(recoID),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text('Loading rating info...'); // Loading state
      } else if (snapshot.hasError) {
        return const Text('Error loading rating info'); // Error state
      } else {
        double calculatedRating = snapshot.data?['calculatedRating'] ?? 0.0;
        int numberOfRatings = snapshot.data?['numberOfRatings'] ?? 0;

        return Row(
          children: [
            Text('$calculatedRating'),
            Text(' ($numberOfRatings reviews)', style: const TextStyle(fontStyle: FontStyle.italic)),
          ],
        );
      }
    },
  );
}
