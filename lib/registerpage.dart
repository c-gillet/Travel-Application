import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'style.dart';
import 'homepage.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Add this line to prevent resizing when the keyboard is shown
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/bg_image/login_bg.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(
          child: RegisterForm(),
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool saving = false;
  final _authentification = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String username = '';
  String password = '';
  String error = ''; // New variable to store error messages

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username.';
    }

    // Check if the username contains spaces
    if (value.contains(' ')) {
      return 'Username cannot contain spaces.';
    }


    return null; // Return null if the username is valid
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address.';
    }

    // Use a regular expression to check if the email is valid
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address.';
    }

    return null; // Return null if the email is valid
  }


  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }

    // Check if the password meets your criteria (e.g., minimum length)
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    return null; // Return null if the password is valid
  }



  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: saving,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.only(top: 100.0),
            child: ListView(
              children: [
                const Center(
                  child: Text(
                    'Sign up',
                    style: TextStyle(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold,),
                  ),
                ),
                const SizedBox(height: 70.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      username = value.toLowerCase(); // Convert to lowercase
                      error = ''; // Clear error when the username changes
                    });
                  },
                  validator: validateUsername, // Add the validation function
                ),
                const SizedBox(
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
                  },
                  validator: validateEmail,
                ),
                const SizedBox(
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
                  validator: validatePassword,
                ),
                const SizedBox(
                  height: 40,
                ),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                      try {
                        // Check if the username already exists
                          final existingUser = await FirebaseFirestore.instance
                              .collection('users')
                              .where('userName', isEqualTo: username)
                              .get();

                          if (existingUser.docs.isNotEmpty) {
                            setState(() {
                              error = 'Username already exists. Please choose another one.';
                            });
                            return;
                          }

                          // Continue with user registration if the username is unique
                          final newUser = await _authentification.createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          await FirebaseFirestore.instance.collection('users').doc(newUser.user!.uid).set({
                            'userName': username,
                            'email': email,
                          });

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
                      };
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
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 40,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already registered ?', style: TextStyle(fontWeight: FontWeight.bold,),),
                    TextButton(
                      child: const Text('Log in', style: TextStyle(color:Colors.blueGrey, fontWeight: FontWeight.bold,),),
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
      ),
    );
  }
}
