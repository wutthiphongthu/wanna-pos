import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Initialize Firebase สำหรับ Auth + Firestore
/// ใช้ Firebase Auth เสมอ
Future<void> initializeFirebaseIfNeeded() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      // ignore: avoid_print
      print('Firebase: initialized');
    }
  } catch (e, st) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('Firebase init failed: $e');
      // ignore: avoid_print
      print(st);
    }
  }
}
