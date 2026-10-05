import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for the `cultivatec-appstore` project
/// (the database used for the Google Play / App Store builds).
///
/// Values come from the project's web config, `google-services.json` (Android)
/// and `GoogleService-Info.plist` (iOS). `main.dart` initializes Firebase with
/// `FirebaseConfig.currentPlatform`, so this is the source of truth at runtime.
class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        // Windows/Linux desktop have no native Firebase config — use web.
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAnXyIDhyY5Zbu4oAxEHKMECIdueCgyHxQ',
    authDomain: 'cultivatec-appstore.firebaseapp.com',
    projectId: 'cultivatec-appstore',
    storageBucket: 'cultivatec-appstore.firebasestorage.app',
    messagingSenderId: '906949781222',
    appId: '1:906949781222:web:bcbf578b47600057bf3d27',
    measurementId: 'G-ZZQ7XNMWQ1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-ICwh2VnbI3qI27yCNRQaElUg-CTuCms',
    appId: '1:774790349230:android:815102d5dd5a57bd8f883f',
    messagingSenderId: '774790349230',
    projectId: 'wokov-dev',
    storageBucket: 'wokov-dev.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDUOQpxxktH-WohAWU3k3KZMfQLb0iGsSk',
    appId: '1:906949781222:ios:8b17c20a1b53bf63bf3d27',
    messagingSenderId: '906949781222',
    projectId: 'cultivatec-appstore',
    storageBucket: 'cultivatec-appstore.firebasestorage.app',
    iosBundleId: 'com.cultivatec.cultivatecApp',
  );
}
