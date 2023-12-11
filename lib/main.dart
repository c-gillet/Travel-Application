import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'style.dart';
import 'homepage.dart';
import 'loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Application',
      theme: ThemeData(
        primaryColor: AppColor.LightBlue,
        //primarySwatch: AppColor.LightPink,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // ConnectionState.active means that the stream has emitted at least one item
            // and will continue to do so as the authentication state changes.
            if (snapshot.hasData) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          } else {
            // ConnectionState.waiting means the stream is still waiting for data.
            // You might want to display a loading indicator or handle this case differently.
            return CircularProgressIndicator(); // Replace with your loading indicator widget
          }
        },
      ),

    );
  }
}

