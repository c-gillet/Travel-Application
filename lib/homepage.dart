import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'style.dart';
import 'bottombar.dart';
import 'buildRecommendationDetails.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;



class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<_HomePageState> streamBuilderKey =
  GlobalKey<_HomePageState>();
  String selectedCity = 'All';
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

  void _selectCity(String city) {
    setState(() {
      selectedCity = city;
    });
  }


  List<Widget> generateImageWidgets(
      BuildContext context, List<DocumentSnapshot> docs, String type) {
    final double paddingValue = 30.0;

    List<Widget> widgets = [];

    bool hasRecommendations = false;

    for (int index = 0; index < docs.length; index++) {
      final String city = docs[index]['city']; // Assuming 'city' is a field in your documents

      if ((docs[index]['type'] == type || type == '') &&
          (selectedCity == 'All' || city == selectedCity)) {
        hasRecommendations = true;
        widgets.add(
          Padding(
            padding: EdgeInsets.all(paddingValue),
            child: Column(
              children: [
                buildListTile(context, docs[index], username, paddingValue),
              ],
            ),
          ),
        );
      }
    }

    if (!hasRecommendations) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('There are no recommendations.'),
        ),
      );
    }

    return widgets;
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
                    SizedBox(height: 25,),
                    Container(
                      height: 90, // Fixed height for the AppBar
                      child: Stack(
                        children: [
                          AppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            bottom: PreferredSize(
                              preferredSize: const Size.fromHeight(48.0),
                              child: Container(
                                color: const Color(0xFFFCC7BF),
                                child: const TabBar(
                                  indicatorColor: AppColor.LightBlue,
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
                            //title: const Text('Home Page', style: TextStyle(color: Colors.white)),

                          ),
                          Positioned(
                            top: 0,
                            left: MediaQuery.of(context).size.width / 2 - 150,
                            child: Container(
                              width: 300,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColor.LightPink,
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    PopupMenuButton<String>(
                                      icon: Container(
                                          child: Row(
                                            children: [
                                              Icon(Icons.search, color: Colors.white),
                                            ],
                                          )),
                                      onSelected: _selectCity,
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          'All',
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
                                          'Jejudo',
                                        ].map<PopupMenuEntry<String>>((String city) {
                                          return PopupMenuItem<String>(
                                            value: city,
                                            child: Text(city),
                                          );
                                        }).toList();
                                      },
                                    ), // Add some space between the dropdown and the selected city
                                    Text(
                                      selectedCity,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
  final _authentification = FirebaseAuth.instance;
  User? loggedUser;
  String? username;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  String? selectedType;
  String? selectedCity;
  String? selectedRating;
  late TextEditingController addressController;
  late XFile? pickedImage = null;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool showErrorMessage = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    selectedType = null;
    selectedCity = null;
    addressController = TextEditingController();
    selectedRating = null;
    loading = false;
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
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.8,
          padding: EdgeInsets.all(16.0),
          child: ListView(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add new recommendation',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Title'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      Container(
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          hint: Text('Recommendation type'),
                          value: selectedType,
                          elevation: 16,
                          style: TextStyle(color: Colors.black, fontSize: 16),
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
                      Container(
                        height: 50,
                        child: TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(labelText: 'Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          hint: Text('Rating'),
                          value: selectedRating,
                          elevation: 16,
                          style: TextStyle(color: Colors.black, fontSize: 16),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRating = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please rate your recommendation';
                            }
                            return null;
                          },
                          items: ['1', '2', '3', '4', '5'].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: DropdownButtonFormField<String>(
                          hint: Text('Select city'),
                          value: selectedCity,
                          elevation: 16,
                          style: TextStyle(color: Colors.black, fontSize: 16),
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
                          items: cities
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(labelText: 'Address'),
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
                TextButton.icon(
                  onPressed: () async {
                    XFile? image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    setState(() {
                      pickedImage = image;
                      showErrorMessage =
                          pickedImage == null;
                    });
                  },
                  icon: Icon(Icons.add_a_photo),
                  label: Text('Add picture'),
                ),
                if (showErrorMessage && pickedImage == null)
                  Text(
                    'Please add a picture',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                if (pickedImage != null)
                  Text(
                    'Image successfully loaded!',
                    style: TextStyle(color: Colors.green, fontSize: 13),
                  ),
                SizedBox(height: 8,),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      showErrorMessage =
                          _formKey.currentState?.validate() == false ||
                              selectedType == null ||
                              selectedCity == null ||
                              selectedRating == null ||
                              pickedImage == null;
                      loading = !showErrorMessage;
                    });

                    if (!showErrorMessage) {
                      await addRecommendation().then((_) {
                        setState(() {
                          loading = false;
                        });
                      });
                    }
                  },
                  child: loading
                      ? CircularProgressIndicator()
                      : Text('Add'),
                ),


              ],
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> addRecommendation() async {
    try {
      if (pickedImage == null) {
        setState(() {
          showErrorMessage = true;
          loading = false;
        });
        return;
      }
      
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('recommendation_images/${DateTime.now().millisecondsSinceEpoch}.${pickedImage!.path.split('.').last}');

      await storageRef.putFile(File(pickedImage!.path));

      final imageUrl = await storageRef.getDownloadURL();

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
        'username': username,
        'recoRating': selectedRating,
        'picture': imageUrl,
      });

      titleController.clear();
      descriptionController.clear();
      selectedType = null;
      selectedCity = null;
      selectedRating = null;
      addressController.clear();
      pickedImage = null;
      Navigator.pop(context);
    } catch (error) {
      print('Error adding recommendation: $error');
      setState(() {
        loading = false;
      });
    }
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
}
