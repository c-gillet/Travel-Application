// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAsk2PerJvxXlDNZcpnB5x5WWKHVDAJ8PU',
    appId: '1:758459920016:web:902f7fb0cae69075557215',
    messagingSenderId: '758459920016',
    projectId: 'traveldb-89cec',
    authDomain: 'traveldb-89cec.firebaseapp.com',
    storageBucket: 'traveldb-89cec.appspot.com',
    measurementId: 'G-XXGL1KEVKH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2tMaHMT-aNHb5vT-sQ7rw9E3twHws0q0',
    appId: '1:758459920016:android:f25c25c6588bccd6557215',
    messagingSenderId: '758459920016',
    projectId: 'traveldb-89cec',
    storageBucket: 'traveldb-89cec.appspot.com',
  );
}
