import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registerpage.dart';
import 'style.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String email = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: AppColor.LightPink,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/bg_image/login_bg.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SizedBox(
          //height: 350,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/bg_image/login_bg.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(30.0),
                  margin: const EdgeInsets.only(top: 100.0),
                  decoration: BoxDecoration(
                    //color: Colors.white, // White background color
                    borderRadius: BorderRadius.circular(20.0), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.6),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Enter your email address to reset your password',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            email = value.trim();
                            error = ''; // Clear error when email changes
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              // Attempt to send a password reset email
                              await _auth.sendPasswordResetEmail(email: email);
    
                              // Show success message
                              _scaffoldKey.currentState!.showBottomSheet(
                                    (context) => Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800], // Dark grey background color
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                  ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.check,
                                            color: Colors.green,
                                            size: 30,
                                          ),
                                          SizedBox(width: 16),
                                          Text(
                                            'An email to reset your password has been sent',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white, // Text color
                                            ),
                                          ),
                                        ],
                                      ),
                                ),
                              );
    
                              await Future.delayed(Duration(seconds: 2));
                            } catch (e) {
                              // Handle specific error scenarios
                              if (e is FirebaseAuthException) {
                                if (e.code == 'user-not-found') {
                                  // Email does not exist, show an error message
                                  setState(() {
                                    error = 'Email does not exist';
                                  });
                                } else {
                                  // Handle other FirebaseAuthException errors
                                  setState(() {
                                    error = e.message!;
                                  });
                                }
                              } else {
                                // Handle other types of errors
                                setState(() {
                                  error = 'An error occurred';
                                });
                              }
                            } finally {
                              // Close the bottom sheet after delay
                              await Future.delayed(Duration(seconds: 2));
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: AppColor.LightPink, // Pink button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          minimumSize: const Size(200, 50), // Set width and height
                        ),
                        child: const Text('Reset Password'),
                      ),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

