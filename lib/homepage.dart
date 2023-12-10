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
import 'buildRecommendationDetails.dart';


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


    return List.generate(docs.length, (index) {
      if (docs[index]['type'] == type || type == '') {
        return Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            children: [
              buildListTile(context, docs[index], username, paddingValue),


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
