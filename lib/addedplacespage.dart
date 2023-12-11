import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_application/style.dart';

import 'bottombar.dart';
import 'buildRecommendationDetails.dart';

class AddedPlacesPage extends StatefulWidget {
  @override
  _AddedPlacesPageState createState() => _AddedPlacesPageState();
}

class _AddedPlacesPageState extends State<AddedPlacesPage> {
  late List<DocumentSnapshot> addedList;
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String? username;


  @override
  void initState() {
    super.initState();
    getCurrentUser();
    addedList = [];
    fetchAddedlist();
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
            fetchAddedlist();
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void fetchAddedlist() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('recommendations')
          .where('username', isEqualTo: username)
          .get();

      setState(() {
        addedList = querySnapshot.docs;
      });
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Added Places'),
        backgroundColor: AppColor.SalmonPink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: addedList.isEmpty
            ? const Center(
          child: Text("You didn't add any recommendation"),
        )
            : ListView(
          children: addedList.map((DocumentSnapshot document) {
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

                    return Column(
                      children: [
                        Stack(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                showDetailsDialog(context, recoID);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.white, Colors.white30],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
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
                                            showDetailsDialog(context, recoID);
                                          },
                                        ),
                                      ],
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

    );
  }
}

