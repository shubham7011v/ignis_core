// File generated manually due to CLI failure.
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
    apiKey: 'AIzaSyAwyOFtyCXwblxrsOhXj2sImNO5u_FcvI0',
    appId:
        '1:233564815800:web:b4957d103e68f88aed4f4d', // Guessed from Android pattern
    messagingSenderId: '233564815800',
    projectId: 'veil-prod-shubham',
    authDomain: 'veil-prod-shubham.firebaseapp.com',
    storageBucket: 'veil-prod-shubham.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfgtl67m885k5O5IrcY0T4d05-KM4_ncE',
    appId: '1:892343603637:android:0eefefa9e34528c83889fc',
    messagingSenderId: '892343603637',
    projectId: 'vivaah-ignis-prod',
    storageBucket: 'vivaah-ignis-prod.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyADJh5qecD2bpURs4Twe2z5WXiEZpU_IBs',
    appId: '1:892343603637:ios:1b050c02b0b179743889fc',
    messagingSenderId: '892343603637',
    projectId: 'vivaah-ignis-prod',
    storageBucket: 'vivaah-ignis-prod.firebasestorage.app',
    iosBundleId: 'com.ignis.vivaah',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAwyOFtyCXwblxrsOhXj2sImNO5u_FcvI0',
    appId: '1:233564815800:ios:b4957d103e68f88aed4f4d', // Placeholder
    messagingSenderId: '233564815800',
    projectId: 'veil-prod-shubham',
    storageBucket: 'veil-prod-shubham.firebasestorage.app',
    iosBundleId: 'com.veil.bluff',
  );
}