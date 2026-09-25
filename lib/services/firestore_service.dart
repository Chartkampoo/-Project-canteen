// หัวข้อ 10: Saving Data On Cloud Storage (Cloud Firestore)
// จัดการข้อมูลโต๊ะอาหารทั้งหมด: อ่านแบบ real-time, จอง, ยกเลิกจอง

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/canteen_table.dart';

class FirestoreService {
  final CollectionReference _tables =
      FirebaseFirestore.instance.collection('canteen_tables');

  // ใช้ Stream เพื่อให้หน้าจออัปเดตอัตโนมัติเมื่อมีคนจอง/ยกเลิกโต๊ะ
  Stream<List<CanteenTable>> get tablesStream {
    return _tables.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              CanteenTable.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Stream<List<CanteenTable>> tablesByLocation(String location) {
    return _tables
        .where('location', isEqualTo: location)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                CanteenTable.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addTable(CanteenTable table) async {
    await _tables.doc(table.id).set(table.toMap());
  }

  // จองโต๊ะ: ใช้ transaction กันปัญหาสองคนกดจองพร้อมกัน
  Future<bool> bookTable({
    required String tableId,
    required String uid,
    required String userName,
  }) async {
    final docRef = _tables.doc(tableId);
    return FirebaseFirestore.instance.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() as Map<String, dynamic>;
      if (data['isBooked'] == true) {
        return false; // มีคนจองไปก่อนแล้ว
      }
      transaction.update(docRef, {
        'isBooked': true,
        'bookedByUid': uid,
        'bookedByName': userName,
      });
      return true;
    });
  }

  Future<void> cancelBooking(String tableId) async {
    await _tables.doc(tableId).update({
      'isBooked': false,
      'bookedByUid': null,
      'bookedByName': null,
    });
  }
}
