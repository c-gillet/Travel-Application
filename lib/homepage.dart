import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'favoritepage.dart';
import 'schedulepage.dart';
import 'profilepage.dart';
import 'style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.hotel)),
                Tab(icon: Icon(Icons.fastfood)),
                Tab(icon: Icon(Icons.museum)),
                Tab(icon: Icon(Icons.card_giftcard)),
              ],
            ),
            title: const Text('Home Page'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // SEARCH AREA
                },
              ),
            ],
          ),
          body: const TabBarView(
            children: [
              // HOME
              Text('Home with random recommendations'),

              // HOTEL
              Text('Hotel recommendations'),

              // FOOD
              Text('Food recommendations'),

              // MUSEUM
              Text('Museum recommendations'),

              // GIFT
              Text('Gift?? recommendations'),
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
            child: Icon(Icons.add),
          ),

          // BOTTOM NAVIGATION BAR
          bottomNavigationBar: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FavoritePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SchedulePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
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
  late TextEditingController addressController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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

    return SingleChildScrollView(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.8,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add new recommendation',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
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
                    SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        hint: Text('Recommendation type'),
                        value: selectedType,
                        elevation: 16,
                        style: TextStyle(color: Colors.deepPurple, fontSize: 16),
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
                        items: ['Hotel', 'Restaurant', 'Monument / Museum', 'Other']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        hint: Text('Select city'),
                        value: selectedCity,
                        elevation: 16,
                        style: TextStyle(color: Colors.deepPurple, fontSize: 16),
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
                        items: cities.map<DropdownMenuItem<String>>((String value) {
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
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() &&
                      selectedType != null &&
                      selectedCity != null) {
                    addRecommendation();
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
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
      'username': username,
    });

    titleController.clear();
    descriptionController.clear();
    selectedType = null;
    selectedCity = null;
    addressController.clear();
    Navigator.pop(context);
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
}
