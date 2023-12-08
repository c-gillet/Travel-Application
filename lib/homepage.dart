import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'favoritepage.dart';
import 'schedulepage.dart';
import 'profilepage.dart';
import 'style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FavoritePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SchedulePage()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
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
                          pickedImage == null; // Update showErrorMessage
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
                      loading = !showErrorMessage; // Mettez à jour loading seulement si showErrorMessage est faux
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
          .child('recommendation_images/${DateTime.now().millisecondsSinceEpoch}');

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
