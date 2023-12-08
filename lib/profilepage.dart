import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_application/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'LoginPage.dart';
import 'bottombar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authentification = FirebaseAuth.instance;
  User? loggedUser;
  String? username;
  String? profilePictureUrl;
  String? selectedAvatarUrl;
  int _currentIndex = 3;

  @override
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
            profilePictureUrl = currentUserInfo.data()!['profilePictureUrl'];
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _selectAvatar(String avatarUrl) async {
    try {
      setState(() {
        selectedAvatarUrl = avatarUrl;
        profilePictureUrl = avatarUrl;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(loggedUser!.uid)
          .update({
        'profilePictureUrl': avatarUrl,
      });
    } catch (e) {
      print('Error selecting avatar: $e');
    }
  }

  Widget _buildProfilePicture() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.LightPink,
        image: profilePictureUrl != null
            ? DecorationImage(
          image: NetworkImage(profilePictureUrl!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: profilePictureUrl == ""
          ? Icon(
        Icons.image,
        color: Colors.white,
        size: 40,
      )
          : null,
    );
  }

  void _showAvatarsModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 200,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: avatarUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _selectAvatar(avatarUrls[index]);
                    Navigator.pop(context); // Close the modal
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(avatarUrls[index]),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: AppColor.SalmonPink,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false, // Clear the navigation stack
                );
              } catch (e) {
                print("Error during sign-out: $e");
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  _buildProfilePicture(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        _showAvatarsModal();
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                        ),
                        child: Icon(
                          Icons.edit,
                          color: AppColor.LightPink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Text(
                username != null ? 'Hi $username!' : 'Hi user!',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10,),
              Text(
                'Email: ${loggedUser!.email!}',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40,),
              Container(
                height: 60, // Adjust the height as needed
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColor.LightPink, width: 1),
                  ),
                  child: ListTile(
                    title: const Text('Wish List'),
                    leading: const Icon(Icons.favorite),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () {},
                  ),
                ),
              ),
              Container(
                height: 60, // Adjust the height as needed
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColor.LightPink, width: 1),
                  ),
                  child: ListTile(
                    title: const Text('Places Added'),
                    leading: const Icon(Icons.add),
                    trailing: const Icon(Icons.navigate_next),
                    onTap: () {},
                  ),
                ),
              ),
              Container(
                height: 60, // Adjust the height as needed
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColor.LightPink, width: 1),
                  ),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelText: '   Choose Currency',
                      labelStyle: const TextStyle(color: Colors.black),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(Icons.attach_money),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'WON', child: Text('Korean Won')),
                      DropdownMenuItem(value: 'USD', child: Text('US Dollar')),
                      DropdownMenuItem(value: 'EUR', child: Text('Euro')),
                      DropdownMenuItem(value: 'GBP', child: Text('British Pound')),
                      DropdownMenuItem(value: 'JPY', child: Text('Japanese Yen')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        // Handle onChanged event
                        print('Selected Currency: $value');
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              Container(
                height: 60,
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColor.LightPink, width: 1),
                  ),
                  child: ElevatedButton(
                    child: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(AppColor.LightPink),
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                              (route) => false, // Clear the navigation stack
                        );
                      } catch (e) {
                        print("Error during sign-out: $e");
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
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

const List<String> avatarUrls = [
  'assets/profile_avatar/default_profile_image.jpg',
  'assets/profile_avatar/koala.png',
  'assets/profile_avatar/giraffe.png',
  'assets/profile_avatar/lion.png',
  'assets/profile_avatar/sea-lion.png',
  'assets/profile_avatar/dog.png',
  'assets/profile_avatar/panda.png',
  'assets/profile_avatar/rabbit.png',
  'assets/profile_avatar/chicken.png',
  'assets/profile_avatar/bear.png',
];
