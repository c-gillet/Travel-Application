import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_application/style.dart';

import 'bottombar.dart';
import 'buildRecommendationDetails.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late List<DocumentSnapshot> wishlist;
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String? username;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    wishlist = [];
    fetchWishlist();
  }

  void getCurrentUser() async {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        final currentUserInfo = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (currentUserInfo.exists) {
          setState(() {
            username = currentUserInfo.data()!['userName'];
            fetchWishlist();
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void fetchWishlist() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('wishList')
          .where('username', isEqualTo: username)
          .get();

      setState(() {
        wishlist = querySnapshot.docs;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _removeFromWishList(BuildContext context, String recoID) async {
    try {
      // Fetch the document ID from the wishlist based on recoID and username
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('wishList')
          .where('username', isEqualTo: username)
          .where('recoID', isEqualTo: recoID)
          .get();

      // Ensure there's at least one document found before showing the confirmation dialog
      if (querySnapshot.docs.isNotEmpty) {
        bool confirmRemove = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Remove from Wishlist'),
              content: const Text('Are you sure you want to remove this item from your wishlist?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Remove'),
                ),
              ],
            );
          },
        );

        if (confirmRemove == true) {
          // Iterate through the result and delete each document
          for (QueryDocumentSnapshot document in querySnapshot.docs) {
            await FirebaseFirestore.instance
                .collection('wishList')
                .doc(document.id)
                .delete();
          }

          // Reload the wishlist after removal
          fetchWishlist();
        }
      }
    } catch (error) {
      print("Failed to remove item from wish list: $error");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Places'),
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.SalmonPink,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.7),
              BlendMode.srcATop,
            ),
            child: Image.asset(
              'assets/bg_image/login_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: wishlist.isEmpty
                ? const Center(
              child: Text('Your wishlist is empty'),
            )
                : ListView(
              children: wishlist.map((DocumentSnapshot document) {
                String recoID = document['recoID'];

                return FutureBuilder(
                  key: ValueKey(recoID),
                  future: FirebaseFirestore.instance
                      .collection('recommendations')
                      .doc(recoID)
                      .get(),
                  builder: (context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return const ListTile(
                          title: Text('Error loading data'),
                        );
                      }

                      if (snapshot.hasData &&
                          snapshot.data!.exists &&
                          snapshot.data!.data()!.containsKey('recoName')) {
                        String name = snapshot.data!.data()!['recoName'];
                        String type = snapshot.data!.data()!['type'];

                        return Column(
                          children: [
                            Stack(
                              children: [
                                Dismissible(
                                  key: UniqueKey(),
                                  onDismissed: (direction) {
                                    _removeFromWishList(context, recoID);
                                  },
                                  background: Container(
                                    color: Colors.red,
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      showDetailsDialog(context, recoID,username);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          key: ValueKey(recoID),
                                          title: Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          //trailing: Icon(Icons.arrow_forward_ios, color: AppColor.LightPink,size: 15,),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.info),
                                                onPressed: () {
                                                  showDetailsDialog(context, recoID, username);
                                                },
                                              ),
                                            ],
                                          ),
                                          leading: IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () {
                                              _removeFromWishList(context, recoID);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      } else {
                        return ListTile(
                          key: ValueKey(recoID),
                          title: const Text('Error Loading Information'),
                        );
                      }
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          key: ValueKey(recoID),
                          title: const Text('Loading...'),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomBar(
        currentIndex: _currentIndex,
        onTabTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),

    );
  }
}

