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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChr6g-KkVQFkrFN-RzVeXHTg8SgnUpCSE',
    appId: '1:443785044404:android:806f93cbb45ee55d1c12e1',
    messagingSenderId: '"443785044404',
    projectId: '"event-planning-app-a66a9',
    storageBucket: 'event-planning-app-a66a9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYv8ssvzqRu6fuYCWjed-06Novr-Ii08w',
    appId: '1:443785044404:ios:3c012c9f8f06a4111c12e1',
    messagingSenderId: '443785044404',
    projectId: 'event-planning-app-a66a9',
    storageBucket: 'event-planning-app-a66a9.firebasestorage.app',
    iosClientId:
        '443785044404-mgrme24793ma8ki2p61mrbn743o2d33o.apps.googleusercontent.com',
    iosBundleId: 'com.example.eventPlanningApp',
  );
}
