// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyBzZb3MRlOJ8NRxhGzM7B3_QkRZ6gpNTb8',
    appId: '1:114484446559:web:ffcfc2df961e5d6682e2ea',
    messagingSenderId: '114484446559',
    projectId: 'flutterauth-f5f3f',
    authDomain: 'flutterauth-f5f3f.firebaseapp.com',
    databaseURL: 'https://flutterauth-f5f3f-default-rtdb.firebaseio.com',
    storageBucket: 'flutterauth-f5f3f.appspot.com',
    measurementId: 'G-XJL7S88WSH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBa-Ie0uo4IJME2-__G6SIGiMl_2OpL330',
    appId: '1:114484446559:android:1018eaf34bd59d9182e2ea',
    messagingSenderId: '114484446559',
    projectId: 'flutterauth-f5f3f',
    databaseURL: 'https://flutterauth-f5f3f-default-rtdb.firebaseio.com',
    storageBucket: 'flutterauth-f5f3f.appspot.com',
  );

}