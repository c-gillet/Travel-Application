import 'homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'style.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Add this line to prevent resizing when the keyboard is shown
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/bg_image/login_bg.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: RegisterForm(),
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _authentification = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String username = '';
  String password = '';
  String error = ''; // New variable to store error messages

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Container(
          margin: EdgeInsets.only(top: 100.0),
          child: ListView(
            children: [
              Center(
                child: Text(
                  'Sign up',
                  style: TextStyle(fontSize: 45, color: Colors.white,fontWeight: FontWeight.bold,),
                ),
              ),
              SizedBox(height: 70.0),
              /*TextFormField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  username = value;
                  print(username);
                },
              ),*/
              SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  email = value;
                  print(email);
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  password = value;
                },
              ),
              SizedBox(
                height: 40,
              ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final newUser = await _authentification
                          .createUserWithEmailAndPassword(
                          email: email, password: password);

                      // Get the newly created user's UID
                      String? uid = newUser.user?.uid;

                      // Store additional user information in Firestore
                      /*await FirebaseFirestore.instance.collection('users').doc(uid).set({
                        'username': username,
                        'email': email,
                        // Add other fields as needed
                      });*/

                      if (newUser.user != null) {
                        _formKey.currentState!.reset();
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      }
                    } catch (e) {
                      // Handle different authentication exceptions
                      setState(() {
                        if (e is FirebaseAuthException) {
                          error = e.message!;
                        } else {
                          error = 'An error occurred';
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColor.LightPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Enter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              // Display error message if there's an error
              if (error.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 40,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already registered ?',style: TextStyle(fontWeight: FontWeight.bold,),),
                  TextButton(
                    child:  Text('Log in',style: TextStyle(color:Colors.blueGrey, fontWeight: FontWeight.bold,),),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              )


            ],
          ),
        ),
      ),
    );
  }
}
