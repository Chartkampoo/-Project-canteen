// หัวข้อ 3: Dart Programming Basics
// - class, constructor, named parameters, factory constructor
// - การแปลง object <-> Map เพื่อเก็บลง Firestore (หัวข้อ 10)

class CanteenTable {
  final String id;
  final String name; // ชื่อโต๊ะ เช่น "โต๊ะ A1"
  final String location; // ชื่อโซน/ที่ตั้ง เช่น "โรงอาหารตึก 1 ชั้น 2"
  final int capacity; // จำนวนที่นั่ง
  final bool isBooked;
  final String? bookedByUid;
  final String? bookedByName;

  const CanteenTable({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    this.isBooked = false,
    this.bookedByUid,
    this.bookedByName,
  });

  // factory constructor: สร้าง object จากข้อมูลที่อ่านมาจาก Firestore
  factory CanteenTable.fromMap(String id, Map<String, dynamic> data) {
    return CanteenTable(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      capacity: data['capacity'] ?? 4,
      isBooked: data['isBooked'] ?? false,
      bookedByUid: data['bookedByUid'],
      bookedByName: data['bookedByName'],
    );
  }

  // แปลง object กลับเป็น Map เพื่อบันทึกลง Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'capacity': capacity,
      'isBooked': isBooked,
      'bookedByUid': bookedByUid,
      'bookedByName': bookedByName,
    };
  }

  // copyWith: pattern ที่ใช้บ่อยใน Dart สำหรับสร้าง object ใหม่จากของเดิม
  CanteenTable copyWith({bool? isBooked, String? bookedByUid, String? bookedByName}) {
    return CanteenTable(
      id: id,
      name: name,
      location: location,
      capacity: capacity,
      isBooked: isBooked ?? this.isBooked,
      bookedByUid: bookedByUid,
      bookedByName: bookedByName,
    );
  }
}
  
