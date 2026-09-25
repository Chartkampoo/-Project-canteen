class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String studentId;
  final bool isAdmin; // เพิ่มใหม่: true = แอดมิน/เจ้าหน้าที่โรงอาหาร

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.studentId,
    this.isAdmin = false, // ค่าเริ่มต้น: ทุกคนที่สมัครใหม่ไม่ใช่แอดมิน
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      studentId: data['studentId'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'studentId': studentId,
      'isAdmin': isAdmin,
    };
  }
}