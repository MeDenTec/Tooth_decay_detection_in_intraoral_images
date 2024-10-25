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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCTz4jQ_dp0gbpKqgT9hvgbZfDSZqfME7o',
    appId: '1:705279424700:web:13cac9c6d88e440b0f38b9',
    messagingSenderId: '705279424700',
    projectId: 'dmft-newapp',
    authDomain: 'dmft-newapp.firebaseapp.com',
    storageBucket: 'dmft-newapp.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCfBMPoJAF6qgkPX19fAh-6wk0-BXMHu58',
    appId: '1:705279424700:android:5dfb4d25883232650f38b9',
    messagingSenderId: '705279424700',
    projectId: 'dmft-newapp',
    storageBucket: 'dmft-newapp.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCOUyyjshaoEV-Uw0DWVwZy4vCNp7Cc1R4',
    appId: '1:705279424700:ios:9f5e2323a37c888d0f38b9',
    messagingSenderId: '705279424700',
    projectId: 'dmft-newapp',
    storageBucket: 'dmft-newapp.appspot.com',
    iosBundleId: 'com.example.dmftApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCOUyyjshaoEV-Uw0DWVwZy4vCNp7Cc1R4',
    appId: '1:705279424700:ios:9f5e2323a37c888d0f38b9',
    messagingSenderId: '705279424700',
    projectId: 'dmft-newapp',
    storageBucket: 'dmft-newapp.appspot.com',
    iosBundleId: 'com.example.dmftApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCTz4jQ_dp0gbpKqgT9hvgbZfDSZqfME7o',
    appId: '1:705279424700:web:8e73fba6578f5fc90f38b9',
    messagingSenderId: '705279424700',
    projectId: 'dmft-newapp',
    authDomain: 'dmft-newapp.firebaseapp.com',
    storageBucket: 'dmft-newapp.appspot.com',
  );
}
