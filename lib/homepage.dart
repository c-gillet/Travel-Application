import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'commentpage.dart';
import 'favoritepage.dart';
import 'schedulepage.dart';
import 'profilepage.dart';
import 'style.dart';
import 'bottombar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authentification = FirebaseAuth.instance;
  User? loggedUser;

  String? username;
  int _currentIndex = 0;

  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = _authentification.currentUser;
      if (user != null) {
        loggedUser = user;

        final currentUserInfo =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (currentUserInfo.exists) {
          setState(() {
            username = currentUserInfo.data()!['userName'];
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xFFFCC7BF, {
          50: Color(0xFFFCC7BF),
          100: Color(0xFFFCC7BF),
          200: Color(0xFFFCC7BF),
          300: Color(0xFFFCC7BF),
          400: Color(0xFFFCC7BF),
          500: Color(0xFFFCC7BF),
          600: Color(0xFFFCC7BF),
          700: Color(0xFFFCC7BF),
          800: Color(0xFFFCC7BF),
          900: Color(0xFFFCC7BF),
        }),
      ),
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
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
              Container(
                child: Column(
                  children: [
                    Container(
                      height: 90,
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(48.0),
                          child: Container(
                            color: const Color(0xFFFCC7BF),
                            child: const TabBar(
                              tabs: [
                                Tab(icon: Icon(
                                    Icons.home, color: Colors.white)),
                                Tab(icon: Icon(
                                    Icons.hotel, color: Colors.white)),
                                Tab(icon: Icon(
                                    Icons.fastfood, color: Colors.white)),
                                Tab(icon: Icon(
                                    Icons.museum, color: Colors.white)),
                                Tab(icon: Icon(
                                    Icons.card_giftcard, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        title: const Text('Home Page', style: TextStyle(
                            color: Colors.white)),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              // SEARCH AREA
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // HOME
                          FutureBuilder(
                            future: _getRecommendations(),
                            builder: (context,
                                AsyncSnapshot<List<Recommendation>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<Widget> recommendationWidgets = snapshot
                                    .data!
                                    .map((recommendation) =>
                                    _buildRecommendationWidget(recommendation))
                                    .toList();
                                return SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: recommendationWidgets,
                                  ),
                                );
                              }
                            },
                          ),

                          Text('Hotels'),
                          Text('Fast Foods'),
                          Text('this'),
                          Text('Other'),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // BUTTON FOR ADDING A NEW ELEMENT ON THE HOME PAGE
            },
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: CommonBottomBar(
            currentIndex: _currentIndex,
            onTabTapped: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<List<Recommendation>> _getRecommendations() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(
        'recommendations').get();

    List<Recommendation> recommendations = querySnapshot.docs.map((document) {
      return Recommendation(
        ID: document['recoID'],
        title: document['recoName'],
        description: document['recoDescription'],
        address: document['address'],
        city: document['city'] ,
        rating: document['recoRating'],
        type: document['type'] ,

      );
    }).toList();

    return recommendations;
  }

  Widget _buildRecommendationWidget(Recommendation recommendation) {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              _showRecommendationDetails(recommendation);
            },
            child: Container(
              color: const Color(0xFF99C7C1),
              width: MediaQuery
                  .of(context)
                  .size
                  .width - 2 * 30.0,
              height: MediaQuery
                  .of(context)
                  .size
                  .width - 2 * 30.0,
              child: Container(
                margin: EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/bg_image/login_bg.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(recommendation.title, style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
              Row(
                children: [
                  Icon(Icons.star_border),
                  Text(recommendation.rating),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRecommendationDetails(Recommendation recommendation) {
    bool isLiked = false;

    // Get the current user's username (replace with your logic to get the username)
    String username = FirebaseAuth.instance.currentUser?.displayName ?? "";

    // Check if the recommendation is already in the wish list
    Future<bool> checkIfLiked() async {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('wishList')
          .where('username', isEqualTo: username)
          .where('recoID', isEqualTo: recommendation.ID)
          .get();
      //print(querySnapshot.docs.isNotEmpty);
      return querySnapshot.docs.isNotEmpty;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: checkIfLiked(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              isLiked = snapshot.data as bool;

              return AlertDialog(
                contentPadding: EdgeInsets.only(bottom: 16.0),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  /*IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: isLiked ? Colors.red : null,
                                    ),
                                    onPressed: () async {
                                      // Toggle the liked state
                                      isLiked = !isLiked;

                                      // Add to the wish list if liked
                                      if (isLiked) {
                                        await _addToWishList(context, recommendation);
                                      }
                                    },
                                  ),*/
                                  Icon(Icons.star_border_outlined),
                                  Text(recommendation.rating),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 20.0),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: 400,
                        ),
                        width: double.maxFinite,
                        child: Image.asset(
                          'assets/bg_image/login_bg.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SizedBox(height: 8),
                            Text(
                              recommendation.title,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_city_rounded),
                                Text(recommendation.city),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.place),
                                Text(recommendation.address),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text("Description : ${recommendation.description}"),
                            SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => FractionallySizedBox(
                                    heightFactor: 2 / 3,
                                    child: Comments(
                                      recoID: recommendation.ID,
                                    ),
                                  ),
                                );
                              },
                              child: Text("Show Comments"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  Future<void> _addToWishList(BuildContext context, Recommendation recommendation) async {
    try {
      // Add elements to the wishList table in the database
      // Assuming you have a 'wishList' collection with fields: 'username', 'recoID'
      await FirebaseFirestore.instance.collection('wishList').add({
        'username': username,
        'recoID': recommendation.ID,
        'wishlistID': "", // Placeholder for auto-generated ID
      }).then((value) {
        // Update the 'ID' field with the auto-generated ID
        value.update({'wishlistID': value.id});

        print("Item added to wish list with ID: ${value.id}");
      });
    } catch (error) {
      print("Failed to add item to wish list: $error");
    }
  }



}



  class Recommendation {
  final String ID;
  final String title;
  final String description;
  final String address;
  final String city;
  final String rating;
  final String type;

  Recommendation({required this.address,required this.city,required this.type,required this.ID, required this.title, required this.description, required this.rating});
}
