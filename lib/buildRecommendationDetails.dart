import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'commentpage.dart';
import 'ratings.dart';

Future<void> _addToWishList(BuildContext context, recoID, username) async {
  try {
    await FirebaseFirestore.instance.collection('wishList').add({
      'username': username,
      'recoID': recoID,
      'wishlistID': "",
    }).then((value) {
      value.update({'wishlistID': value.id});
      //print("Item added to wish list with ID: ${value.id}");
    });
  } catch (error) {
    print("Failed to add item to wish list: $error");
  }
}

Future<void> _removeFromWishList(BuildContext context,recoID, username) async {
  try {
    // Fetch the document ID from the wishlist based on recoID and username
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('wishList')
        .where('username', isEqualTo: username)
        .where('recoID', isEqualTo: recoID)
        .get();

    // Iterate through the result and delete each document
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      await FirebaseFirestore.instance
          .collection('wishList')
          .doc(document.id)
          .delete();
      //print("Item removed from wish list with ID: ${document.id}");
    }

  } catch (error) {
    print("Failed to remove item from wish list: $error");
  }
}


void showDetailsDialogFromGesture(BuildContext context, String recoID) {
  showDetailsDialog(context, recoID);
}

GestureDetector buildListTile(BuildContext context, dynamic document, String? username, double paddingValue) {
  return GestureDetector(
    onTap: () {
      showDetailsDialogFromGesture(context, document['recoID']);
    },
    child: ListTile(
      title: Stack(
        children: [
          Container(
            color: const Color(0xFF99C7C1),
            width: MediaQuery.of(context).size.width - 2 * paddingValue,
            height: MediaQuery.of(context).size.width - 2 * paddingValue,
            child: Container(
              margin: const EdgeInsets.all(8.0),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 400),
                width: double.maxFinite,
                child: document['picture'] is String
                    ? Image.network(
                  document['picture'],
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );

                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Handle the error if the image fails to load
                    print('Error loading image: $error');
                    // Return the fallback image
                    return Image.asset(
                      'assets/bg_image/login_bg.jpg', // Fallback image
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
                  'assets/bg_image/login_bg.jpg', // Fallback image
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('wishList')
                    .where('username', isEqualTo: username)
                    .where('recoID', isEqualTo: document['recoID'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  bool isLiked = snapshot.data?.docs.isNotEmpty ?? false;

                  return GestureDetector(
                    onTap: () async {
                      isLiked = !isLiked;

                      if (isLiked) {
                        await _addToWishList(context, document['recoID'],username);
                      } else {
                        await _removeFromWishList(context, document['recoID'],username);
                      }
                    },
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: isLiked ? 1.2 : 1.0, end: isLiked ? 1.0 : 1.2),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut, // You can experiment with different curves
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : null,
                              size: 35,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(document['recoName'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
            Row(
              children: [
                //const Icon(Icons.star_border),
                //buildRatingInfoWidget(document['recoID']),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}


void showDetailsDialog(BuildContext context, String recoID) {
  FirebaseFirestore.instance
      .collection('recommendations')
      .doc(recoID)
      .get()
      .then((snapshot) {
    if (snapshot.exists) {
      String recoName = snapshot.data()!['recoName'];
      String username = snapshot.data()!['username'];
      String recoDescription = snapshot.data()!['recoDescription'];
      String recoLocation = snapshot.data()!['address'];
      String recoCity = snapshot.data()!['city'];
      String recoType = snapshot.data()!['type'];
      String recoPicture = snapshot.data()!['picture'] ?? 'assets/bg_image/login_bg.jpg';

      IconData iconRecoType;

      if (recoType == "Cafe") {
        iconRecoType = Icons.local_cafe;
      } else if (recoType == "Hotel") {
        iconRecoType = Icons.hotel;
      } else if (recoType == "Restaurant") {
        iconRecoType = Icons.fastfood;
      } else if (recoType == "Monument / Museum") {
        iconRecoType = Icons.museum;
      } else if (recoType == "Other") {
        iconRecoType = Icons.category;
      } else {
        // Set a default icon or handle other cases if needed
        iconRecoType = Icons.place; // Placeholder icon, replace as needed
      }


      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.only(bottom: 16.0),
            content: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 400),
                        width: double.maxFinite,
                        child: recoPicture is String
                            ? Image.network(
                          recoPicture,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            }
                          },
                          errorBuilder: (context, error, stackTrace) {
                            // Handle the error if the image fails to load
                            print('Error loading image: $error');
                            // Return the fallback image
                            return Image.asset(
                              'assets/bg_image/login_bg.jpg', // Fallback image
                              fit: BoxFit.cover,
                            );
                          },
                        )
                            : Image.asset(
                          'assets/bg_image/login_bg.jpg', // Fallback image
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(recoName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.star_border),
                                      buildRatingInfoWidget(recoID),
                                      TextButton(
                                        onPressed: () {
                                          showRatingDialog(context, recoID, username);
                                        },
                                        child: const Text('Rate', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline,),),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => FractionallySizedBox(
                                          heightFactor: 2 / 3,
                                          child: Comments(recoID: recoID),
                                        ),
                                      );
                                    },
                                    child: const Text("Show Comments"),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.topLeft,
                                        child: Text("added by $username", textAlign: TextAlign.start),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_city_rounded),
                                    Expanded(
                                      child: Text(" City: $recoCity"),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.place),
                                    Expanded(
                                      child: Text(" $recoLocation"),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(iconRecoType),
                                    Expanded(
                                      child: Text(" $recoType"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(recoDescription, textAlign: TextAlign.justify),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 20.0),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Handle the case where the document doesn't exist
      print("Document does not exist");
    }
  }).catchError((error) {
    // Handle errors during the fetch
    print("Error fetching document: $error");
  });
}
