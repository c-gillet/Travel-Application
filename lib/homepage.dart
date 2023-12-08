import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'favoritepage.dart';
import 'schedulepage.dart';
import 'profilepage.dart';
import 'style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  List<Widget> generateImageWidgets(BuildContext context, List<DocumentSnapshot> docs, String type) {
    final double paddingValue = 30.0;

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
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                              Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 400,
                                ),
                                width: double.maxFinite,
                                child: Image.asset(
                                  'assets/background.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(docs[index]['recoName'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.star_border),
                                      Text(docs[index]['recoRating']),
                                    ],
                                  ),
                                  Text("3 comments")
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                alignment: Alignment.topLeft, // Align the text to the start
                                child: Text(
                                    "add by " + docs[index]['recoID'],
                                    textAlign: TextAlign.start
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                alignment: Alignment.topLeft, // Align the text to the start
                                child: Text(
                                    "Description",
                                    style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                alignment: Alignment.topLeft, // Align the text to the start
                                child: Text(
                                  docs[index]['recoDescription'],
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  color: const Color(0xFF99C7C1),
                  width: MediaQuery.of(context).size.width - 2 * paddingValue,
                  height: MediaQuery.of(context).size.width - 2 * paddingValue,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/background.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(docs[index]['recoName']),
                  Row(
                    children: [
                      Icon(Icons.star_border),
                      Text(docs[index]['recoRating']),
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      } else {
        // You can return null or an empty container for non-"visit" items
        return Container();
      }
    });


  }


  @override
  Widget build(BuildContext context) {
    final double paddingValue = 30.0;

    final List<Widget> listWidgetImages = List.generate(
      5,
          (index) => Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(0), // Set padding to zero
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Material(
                                        shape: CircleBorder(),
                                        clipBehavior: Clip.antiAlias,
                                        child: IconButton(
                                          icon: Icon(Icons.close, size: 20.0),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                    maxHeight: 400,
                                  ),
                                  width: double.maxFinite,
                                  child: Image.asset(
                                    'assets/background.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text('Test of text'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Test of text'),
                                    Row(
                                      children: [
                                        Icon(Icons.star_border),
                                        const Text('4'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },


                    );
                  },
                  child: Container(
                    color: const Color(0xFF99C7C1),
                    width: MediaQuery.of(context).size.width - 2 * paddingValue,
                    height: MediaQuery.of(context).size.width - 2 * paddingValue,
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/background.jpg',
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
                    const Text('Test of text'),
                    Row(
                      children: [
                        Icon(Icons.star_border),
                        const Text('4'),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
    );


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
                  'assets/background.jpg',
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
                                Tab(icon: Icon(Icons.home, color: Colors.white)),
                                Tab(icon: Icon(Icons.hotel, color: Colors.white)),
                                Tab(icon: Icon(Icons.fastfood, color: Colors.white)),
                                Tab(icon: Icon(Icons.museum, color: Colors.white)),
                                Tab(icon: Icon(Icons.card_giftcard, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        title: const Text('Home Page', style: TextStyle(color: Colors.white)),
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
                              stream: FirebaseFirestore.instance.collection('recommendations').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // If the connection is still waiting, return a loading indicator or empty container.
                                  return CircularProgressIndicator(); // or Container();
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
                              stream: FirebaseFirestore.instance.collection('recommendations').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // If the connection is still waiting, return a loading indicator or empty container.
                                  return CircularProgressIndicator(); // or Container();
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
                              stream: FirebaseFirestore.instance.collection('recommendations').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // If the connection is still waiting, return a loading indicator or empty container.
                                  return CircularProgressIndicator(); // or Container();
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
                              stream: FirebaseFirestore.instance.collection('recommendations').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // If the connection is still waiting, return a loading indicator or empty container.
                                  return CircularProgressIndicator(); // or Container();
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
                              stream: FirebaseFirestore.instance.collection('recommendations').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  // If the connection is still waiting, return a loading indicator or empty container.
                                  return CircularProgressIndicator(); // or Container();
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
            },
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: BottomAppBar(
            color: const Color(0xFFFCC7BF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.access_time, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SchedulePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}