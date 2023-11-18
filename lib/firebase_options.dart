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
    apiKey: 'AIzaSyD5zJtjtKxBho4B1N7hiryYzg8V2dbt154',
    appId: '1:500733475144:web:f0af831f5c600c70bc1b7d',
    messagingSenderId: '500733475144',
    projectId: 'bookingapp-ff114',
    authDomain: 'bookingapp-ff114.firebaseapp.com',
    databaseURL: 'https://bookingapp-ff114-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'bookingapp-ff114.appspot.com',
    measurementId: 'G-EY2NMK9BNK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyATy0dmhFlGx-kopTHB6ePYIwJPuX5PD-E',
    appId: '1:500733475144:android:965e6c16f78cc231bc1b7d',
    messagingSenderId: '500733475144',
    projectId: 'bookingapp-ff114',
    databaseURL: 'https://bookingapp-ff114-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'bookingapp-ff114.appspot.com',
  );
}
