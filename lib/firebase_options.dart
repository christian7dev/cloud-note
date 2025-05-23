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
    apiKey: 'AIzaSyC2diZIOk9Bbk8m-8CkL1eKbPR4BPalFaw',
    appId: '1:127759930655:web:eda788a4db72ee2c1c0c2a',
    messagingSenderId: '127759930655',
    projectId: 'cloudnote-78742',
    authDomain: 'cloudnote-78742.firebaseapp.com',
    storageBucket: 'cloudnote-78742.firebasestorage.app',
    measurementId: 'G-RZMBXYETPF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB30fesMqByRx4e6nt6gqD335Gej6-85oo',
    appId: '1:127759930655:android:5586132d4ffb35bd1c0c2a',
    messagingSenderId: '127759930655',
    projectId: 'cloudnote-78742',
    storageBucket: 'cloudnote-78742.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDahi39NAMbfPKQoIyU7HIjJ1lxW5vxFtY',
    appId: '1:127759930655:ios:aa9d1d4a57246e6f1c0c2a',
    messagingSenderId: '127759930655',
    projectId: 'cloudnote-78742',
    storageBucket: 'cloudnote-78742.firebasestorage.app',
    iosBundleId: 'com.example.cloudNote',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDahi39NAMbfPKQoIyU7HIjJ1lxW5vxFtY',
    appId: '1:127759930655:ios:aa9d1d4a57246e6f1c0c2a',
    messagingSenderId: '127759930655',
    projectId: 'cloudnote-78742',
    storageBucket: 'cloudnote-78742.firebasestorage.app',
    iosBundleId: 'com.example.cloudNote',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC2diZIOk9Bbk8m-8CkL1eKbPR4BPalFaw',
    appId: '1:127759930655:web:6dd615456f251cd51c0c2a',
    messagingSenderId: '127759930655',
    projectId: 'cloudnote-78742',
    authDomain: 'cloudnote-78742.firebaseapp.com',
    storageBucket: 'cloudnote-78742.firebasestorage.app',
    measurementId: 'G-PQB68C6E7J',
  );

}