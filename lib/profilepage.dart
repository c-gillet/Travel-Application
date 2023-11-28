import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_application/style.dart';

import 'LoginPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authentification = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }
  void getCurrentUser(){
    try{
      final user = _authentification.currentUser;
      if(user!=null){
        loggedUser=user;
      }
    }catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
              } catch (e) {
                print("Error during sign-out: $e");
              }
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColor.LightPink,
                  //backgroundImage: NetworkImage('https://example.com/profile_image.jpg'),
                ),
                SizedBox(height: 20,),
                Text('Hi ${loggedUser!.email!} !',
                  style: TextStyle(
                    fontSize: 20,
                  ),),
                SizedBox(height: 10,),
                Text('Email : ${loggedUser!.email!}',
                  style: TextStyle(
                    fontSize: 15,
                  ),),
                SizedBox(height: 40,),
                Container(
                  height: 60, // Adjust the height as needed
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: AppColor.LightPink, width: 1),
                    ),
                    child: ListTile(
                      title: Text('Places Already Visited'),
                      leading: const Icon(Icons.favorite),
                      trailing: const Icon(Icons.navigate_next),
                      onTap: () {},
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                Container(
                  height: 60, // Adjust the height as needed
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: AppColor.LightPink, width: 1),
                    ),
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0), // Adjust border color as needed
                        ),
                        labelText: '   Choose Currency',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(Icons.attach_money),
                        ), // Adjust icon and color as needed
                      ),
                      items: const [
                        DropdownMenuItem(value: 'WON', child: Text('Korean Won')),
                        DropdownMenuItem(value: 'USD', child: Text('US Dollar')),
                        DropdownMenuItem(value: 'EUR', child: Text('Euro')),
                        DropdownMenuItem(value: 'GBP', child: Text('British Pound')),
                        DropdownMenuItem(value: 'JPY', child: Text('Japanese Yen')),
                        // Add more currency options as needed
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
                SizedBox(height: 5,),
                Container(
                  height: 60,
                  width: double.infinity,// Adjust the height as needed
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: AppColor.LightPink, width: 1),
                    ),
                    child: ElevatedButton(
                      child: Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(AppColor.LightPink),
                      ),
                      onPressed: () async{
                        try {
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
                        } catch (e) {
                          print("Error during sign-out: $e");
                        }
                      },


                    )
                  ),
                ),



              ]
          ),


        ),

      ),
    );
  }
}
