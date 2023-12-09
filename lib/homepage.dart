import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'bottombar.dart';
import 'commentpage.dart';
import 'favoritepage.dart';
import 'schedulepage.dart';
import 'profilepage.dart';
import 'style.dart';
import 'ratings.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<_HomePageState> streamBuilderKey =
  GlobalKey<_HomePageState>();
  final _authentification = FirebaseAuth.instance;
  bool _isMounted = true;

  User? loggedUser;
  String? username;

  @override
  bool get wantKeepAlive => true;

  void initState() {
    super.initState();
    getCurrentUser();
  }

  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void getCurrentUser() async {
    try {
      final user = _authentification.currentUser;
      if (user != null) {
        loggedUser = user;

        final currentUserInfo = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

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

  List<Widget> generateImageWidgets(
      BuildContext context, List<DocumentSnapshot> docs, String type) {
    final double paddingValue = 30.0;

    Future<void> _addToWishList(BuildContext context, recoID) async {
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

    Future<void> _removeFromWishList(BuildContext context, String recoID) async {
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

    return List.generate(docs.length, (index) {
      if (docs[index]['type'] == type || type == '') {
        return Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
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
                                    constraints: const BoxConstraints(maxHeight: 400,),
                                    width: double.maxFinite,
                                    child: Image.asset(
                                      'assets/bg_image/login_bg.jpg',
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
                                            Text(docs[index]['recoName'],
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.star_border),
                                                buildRatingInfoWidget(docs[index]['recoID']),
                                                TextButton(
                                                  onPressed: () {
                                                    showRatingDialog(context, docs[index]['recoID'], username);
                                                  },
                                                  child: Text(
                                                    'Rate',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                  Colors.transparent,
                                                  builder: (context) =>
                                                      FractionallySizedBox(
                                                        heightFactor: 2 / 3,
                                                        child: Comments(recoID: docs[index]['recoID'],),
                                                      ),
                                                );
                                              },
                                              child: const Text("Show Comments"),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                                alignment: Alignment.topLeft,
                                                // Align the text to the start
                                                child: Text("added by " + docs[index]['username'], textAlign: TextAlign.start)),
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
                                          // Align the text to the start
                                          child: Text(docs[index]['recoDescription'], textAlign: TextAlign.justify,
                                            // Remove the overflow and maxLines properties to show full text if it's long
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:MainAxisAlignment.end,
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
                          child: Image.asset(
                            'assets/bg_image/login_bg.jpg',
                            fit: BoxFit.cover,
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
                                .where('recoID', isEqualTo: docs[index]['recoID'])
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
                                    await _addToWishList(context, docs[index]['recoID']);
                                  } else {
                                    await _removeFromWishList(context, docs[index]['recoID']);
                                  }
                                },
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
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(docs[index]['recoName']),
                        Row(
                          children: [
                            const Icon(Icons.star_border),
                            Text(docs[index]['recoRating'] ?? 'No rating'),
                          ],
                        ),
                      ],
                    ),
                  ),

                ),
              ),
            ],
          ),
        );
      } else {
        // You can return null or an empty container for non-"visit" items
        return Container();
      }
    });// Add this line to return an empty list in case the function completes normally
  }

  @override
  Widget build(BuildContext context) {
    final double paddingValue = 30.0;
    int length = 1;
    int _currentIndex = 0;

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
                      height: 90, // Fixed height for the AppBar
                      child: AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(48.0),
                          child: Container(
                            color: const Color(0xFFFCC7BF),
                            child: const TabBar(
                              tabs: [
                                Tab(
                                    icon: Icon(Icons.home, color: Colors.white)),
                                Tab(
                                    icon: Icon(Icons.hotel, color: Colors.white)),
                                Tab(
                                    icon: Icon(Icons.fastfood, color: Colors.white)),
                                Tab(
                                    icon: Icon(Icons.museum, color: Colors.white)),
                                Tab(
                                    icon: Icon(Icons.card_giftcard, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        title: const Text('Home Page',
                            style: TextStyle(color: Colors.white)),
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
                          SingleChildScrollView(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('recommendations')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // If the connection is still waiting, return a loading indicator or empty container.
                                  return const CircularProgressIndicator(); // or Container();
                                } else if (snapshot.hasError) {
                                  // If there is an error in fetching the data, you can handle it here.
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  // If the data is available, get the list of documents and display the length.
                                  List<DocumentSnapshot> docs = snapshot.data!.docs;
                                  int recommendationsLength = docs.length;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: generateImageWidgets(context, docs, ''),
                                  );
                                }
                              },
                            ),
                          ),

                          // HOTEL
                          SingleChildScrollView(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('recommendations')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // If the connection is still waiting, return a loading indicator or empty container.
                                  return const CircularProgressIndicator(); // or Container();
                                } else if (snapshot.hasError) {
                                  // If there is an error in fetching the data, you can handle it here.
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  // If the data is available, get the list of documents and display the length.
                                  List<DocumentSnapshot> docs = snapshot.data!.docs;
                                  int recommendationsLength = docs.length;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: generateImageWidgets(context, docs, 'Hotel'),
                                  );
                                }
                              },
                            ),
                          ),

                          // FOOD
                          SingleChildScrollView(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('recommendations')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // If the connection is still waiting, return a loading indicator or empty container.
                                  return const CircularProgressIndicator(); // or Container();
                                } else if (snapshot.hasError) {
                                  // If there is an error in fetching the data, you can handle it here.
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  // If the data is available, get the list of documents and display the length.
                                  List<DocumentSnapshot> docs = snapshot.data!.docs;
                                  int recommendationsLength = docs.length;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: generateImageWidgets(context, docs, 'Restaurant'),
                                  );
                                }
                              },
                            ),
                          ),

                          // MUSEUM
                          SingleChildScrollView(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('recommendations')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // If the connection is still waiting, return a loading indicator or empty container.
                                  return const CircularProgressIndicator(); // or Container();
                                } else if (snapshot.hasError) {
                                  // If there is an error in fetching the data, you can handle it here.
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  // If the data is available, get the list of documents and display the length.
                                  List<DocumentSnapshot> docs = snapshot.data!.docs;
                                  int recommendationsLength = docs.length;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: generateImageWidgets(context, docs, 'Monument / Museum'),
                                  );
                                }
                              },
                            ),
                          ),

                          // GIFT
                          SingleChildScrollView(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('recommendations')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // If the connection is still waiting, return a loading indicator or empty container.
                                  return const CircularProgressIndicator(); // or Container();
                                } else if (snapshot.hasError) {
                                  // If there is an error in fetching the data, you can handle it here.
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  // If the data is available, get the list of documents and display the length.
                                  List<DocumentSnapshot> docs = snapshot.data!.docs;
                                  int recommendationsLength = docs.length;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: generateImageWidgets(context, docs, 'Other'),
                                  );
                                }
                              },
                            ),
                          ),
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
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return NewRecommendation();
                },
              );
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
}

class NewRecommendation extends StatefulWidget {
  @override
  _NewRecommendation createState() => _NewRecommendation();
}

class _NewRecommendation extends State<NewRecommendation> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  String? selectedType;
  String? selectedCity;
  late TextEditingController addressController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    selectedType = null;
    selectedCity = null;
    addressController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    List<String> cities = [
      'Seoul',
      'Busan',
      'Incheon',
      'Daegu',
      'Daejeon',
      'Gwangju',
      'Gyeongju',
      'Sokcho',
      'Suwon',
      'Ulsan',
      'Bucheon',
      'Jeonju',
      'Jejudo'
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add new recommendation',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      hint: const Text('Recommendation type'),
                      value: selectedType,
                      elevation: 16,
                      style: const TextStyle(
                          color: Colors.deepPurple, fontSize: 16),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedType = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a recommendation type';
                        }
                        return null;
                      },
                      items: [
                        'Hotel',
                        'Restaurant',
                        'Monument / Museum',
                        'Other'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      hint: const Text('Select city'),
                      value: selectedCity,
                      elevation: 16,
                      style: const TextStyle(
                          color: Colors.deepPurple, fontSize: 16),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCity = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a city';
                        }
                        return null;
                      },
                      items:
                          cities.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    selectedType != null &&
                    selectedCity != null) {
                  addRecommendation();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void addRecommendation() async {
    final recoID =
        FirebaseFirestore.instance.collection('recommendations').doc().id;

    await FirebaseFirestore.instance
        .collection('recommendations')
        .doc(recoID)
        .set({
      'recoID': recoID,
      'recoName': titleController.text,
      'recoDescription': descriptionController.text,
      'city': selectedCity,
      'address': addressController.text,
      'type': selectedType,
    });

    titleController.clear();
    descriptionController.clear();
    selectedType = null;
    selectedCity = null;
    addressController.clear();
    Navigator.pop(context);
  }
}
