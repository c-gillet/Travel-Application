import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'favoritepage.dart';
import 'schedulepage.dart';
import 'profilepage.dart';
import 'style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController cityController;
  late TextEditingController addressController;
  late TextEditingController typeController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    cityController = TextEditingController();
    addressController = TextEditingController();
    typeController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(labelText: 'City'),
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: 'Address'),
                  ),
                  TextFormField(
                    controller: typeController,
                    decoration: InputDecoration(labelText: 'Type'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: titleController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  cityController.text.isEmpty ||
                  addressController.text.isEmpty ||
                  typeController.text.isEmpty
                  ? null
                  : () async {
                final recoID = FirebaseFirestore.instance.collection('recommendations').doc().id;

                await FirebaseFirestore.instance
                    .collection('recommendations')
                    .doc(recoID)
                    .set({
                  'recoID': recoID,
                  'recoName': titleController.text,
                  'recoDescription': descriptionController.text,
                  'city': cityController.text,
                  'address': addressController.text,
                  'type': typeController.text,
                });

                titleController.clear();
                descriptionController.clear();
                cityController.clear();
                addressController.clear();
                typeController.clear();

                Navigator.pop(context); // Close the dialog
              },
              child: Text('Add'),
            ),

          ],
        ),
      ),
    );
  }
}

