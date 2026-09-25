// ไฟล์นี้เป็น "ตัวอย่างโครงร่าง" เท่านั้น
//
// ในโปรเจกต์จริง ห้ามพิมพ์ไฟล์นี้เอง — ให้รันคำสั่งนี้แทน (ดูขั้นตอนใน README.md):
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// คำสั่งนี้จะสร้างไฟล์ firebase_options.dart ที่มีค่า apiKey, appId, projectId ฯลฯ
// ของโปรเจกต์ Firebase จริงของคุณให้อัตโนมัติ แล้วมาทับไฟล์นี้

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions ยังไม่รองรับแพลตฟอร์มนี้ — รัน flutterfire configure',
        );
    }
  }

  // ค่าด้านล่างเป็นค่า "ตัวอย่างเปล่า" ต้องถูกแทนที่ด้วยค่าจริงจาก flutterfire configure
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'REPLACE_ME',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBywnECG1YO5uc_ooJb8OgSO7OVGkxFG54',
    appId: '1:687450555176:web:6078f4d98ebad412b7c61d',
    messagingSenderId: '687450555176',
    projectId: 'worktype-d4b0c',
    authDomain: 'worktype-d4b0c.firebaseapp.com',
    storageBucket: 'worktype-d4b0c.firebasestorage.app',
    measurementId: 'G-2KLC3WN7Z0',
  );
}
