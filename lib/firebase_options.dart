// test commit

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'env_config.dart';

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

  static FirebaseOptions web = FirebaseOptions(
    apiKey: EnvConfig.webApiKey,
    appId: EnvConfig.webAppId,
    messagingSenderId: EnvConfig.messagingSenderId,
    projectId: EnvConfig.projectId,
    authDomain: EnvConfig.authDomain,
    storageBucket: EnvConfig.storageBucket,
    measurementId: EnvConfig.measurementId,
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: EnvConfig.androidApiKey,
    appId: EnvConfig.androidAppId,
    messagingSenderId: EnvConfig.messagingSenderId,
    projectId: EnvConfig.projectId,
    storageBucket: EnvConfig.storageBucket,
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: EnvConfig.iosApiKey,
    appId: EnvConfig.iosAppId,
    messagingSenderId: EnvConfig.messagingSenderId,
    projectId: EnvConfig.projectId,
    storageBucket: EnvConfig.storageBucket,
    iosBundleId: EnvConfig.iosBundleId,
  );

  static FirebaseOptions macos = FirebaseOptions(
    apiKey: EnvConfig.iosApiKey,
    appId: EnvConfig.iosAppId,
    messagingSenderId: EnvConfig.messagingSenderId,
    projectId: EnvConfig.projectId,
    storageBucket: EnvConfig.storageBucket,
    iosBundleId: EnvConfig.iosBundleId,
  );

  static FirebaseOptions windows = FirebaseOptions(
    apiKey: EnvConfig.windowsApiKey,
    appId: EnvConfig.windowsAppId,
    messagingSenderId: EnvConfig.messagingSenderId,
    projectId: EnvConfig.projectId,
    authDomain: EnvConfig.authDomain,
    storageBucket: EnvConfig.storageBucket,
    measurementId: EnvConfig.windowsBundleId,
  );
}
