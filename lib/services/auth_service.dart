// หัวข้อ 11: Authentication With Firebase
// รวมฟังก์ชัน login / register / logout ไว้ที่เดียว เพื่อให้ UI เรียกใช้ง่าย

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // stream นี้ใช้เช็คสถานะ login/logout แบบ real-time (ใช้ใน StreamBuilder ที่ main.dart)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // สมัครสมาชิก + สร้างเอกสารข้อมูลส่วนตัวใน Firestore
  Future<UserCredential> register({
    required String email,
    required String password,
    required String displayName,
    required String studentId,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(displayName);

    final newUser = AppUser(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
      studentId: studentId,
    );

    await _db.collection('users').doc(credential.user!.uid).set(newUser.toMap());

    return credential;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // อ่านข้อมูลส่วนตัวของผู้ใช้ปัจจุบันจาก Firestore
  Future<AppUser?> fetchProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  Future<void> updateProfile(AppUser user) async {
    await _db.collection('users').doc(user.uid).update(user.toMap());
  }
}
