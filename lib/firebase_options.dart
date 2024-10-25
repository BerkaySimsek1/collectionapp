// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyCmV7qovbpWHBKKYM1XqrQoNdDWoMVzu1c',
    appId: '1:651794069374:web:5f65f3cd62b34a0060652f',
    messagingSenderId: '651794069374',
    projectId: 'collectionapp-d4e51',
    authDomain: 'collectionapp-d4e51.firebaseapp.com',
    storageBucket: 'collectionapp-d4e51.appspot.com',
    measurementId: 'G-0RHR9H9Q3H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVrbWaMlKEaUe6QKNhL_LtOtUN5EdDSfo',
    appId: '1:651794069374:android:df3023d4c037072f60652f',
    messagingSenderId: '651794069374',
    projectId: 'collectionapp-d4e51',
    storageBucket: 'collectionapp-d4e51.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDdzPtNBKFsqyX_44zl2Xu5Dbn1oKERo2E',
    appId: '1:651794069374:ios:eef557b8ae5c2a9e60652f',
    messagingSenderId: '651794069374',
    projectId: 'collectionapp-d4e51',
    storageBucket: 'collectionapp-d4e51.appspot.com',
    iosBundleId: 'com.example.collectionapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDdzPtNBKFsqyX_44zl2Xu5Dbn1oKERo2E',
    appId: '1:651794069374:ios:eef557b8ae5c2a9e60652f',
    messagingSenderId: '651794069374',
    projectId: 'collectionapp-d4e51',
    storageBucket: 'collectionapp-d4e51.appspot.com',
    iosBundleId: 'com.example.collectionapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCmV7qovbpWHBKKYM1XqrQoNdDWoMVzu1c',
    appId: '1:651794069374:web:8b8cf398d239602160652f',
    messagingSenderId: '651794069374',
    projectId: 'collectionapp-d4e51',
    authDomain: 'collectionapp-d4e51.firebaseapp.com',
    storageBucket: 'collectionapp-d4e51.appspot.com',
    measurementId: 'G-8R51Q364QR',
  );
}
