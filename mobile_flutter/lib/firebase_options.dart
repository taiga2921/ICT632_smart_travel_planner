import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBp3jAaP0m_4LgZdzH5WoxJJR8DrMehKC8',
    appId: '1:567887601717:android:8cafcb5ad30bb47724517c',
    messagingSenderId: '567887601717',
    projectId: 'smart-travel-planner-ea644',
    storageBucket: 'smart-travel-planner-ea644.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'smart-travel-planner-ea644',
    storageBucket: 'smart-travel-planner-ea644.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_BUNDLE_ID',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'smart-travel-planner-ea644',
    storageBucket: 'smart-travel-planner-ea644.appspot.com',
    authDomain: 'smart-travel-planner-ea644.firebaseapp.com',
  );
}