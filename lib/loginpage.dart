import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registerpage.dart';
import 'style.dart';
import 'resetpasswordpage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _authentication = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Container(
          margin: const EdgeInsets.only(top: 100.0),
          child: ListView(
            children: [
              const Center(
                child: Text(
                  'Travel Guide App',
                  style: TextStyle(
                    fontSize: 45,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 70.0),
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
                  //print(email);
                },
                validator: validateEmail,
              ),
              const SizedBox(
                height: 40,
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
                height: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final currentUser = await _authentication
                            .signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        if (currentUser.user != null) {
                          _formKey.currentState!.reset();
                        }
                      } catch (e) {
                        setState(() {
                          if (e is FirebaseAuthException) {
                            //error = e.message!;
                            error = 'Email or password are incorrect.';
                          } else {
                            error = 'An error occurred';
                          }
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColor.LightPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Log In',
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
              const SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()));
                    },
                  )
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


