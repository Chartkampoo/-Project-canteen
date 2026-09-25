# 🍽️ Canteen Booking App

แอปจองโต๊ะอาหารในโรงอาหาร พัฒนาด้วย **Flutter** + **Firebase**

## คุณสมบัติหลัก

- สมัครสมาชิก / เข้าสู่ระบบด้วย Firebase Authentication
- ดูรายการโต๊ะอาหารแบบ real-time และจอง/ยกเลิกโต๊ะ (ป้องกันการจองซ้ำด้วย Firestore Transaction)
- กรองโต๊ะตามสถานที่/โซนในโรงอาหาร
- ดูเมนูแนะนำประจำวันผ่าน REST API
- บันทึกข้อมูลโปรไฟล์และ token ด้วย Shared Preferences และ Secure Storage
- ระบบแอดมินสำหรับเพิ่ม/ลบโต๊ะ

## เทคโนโลยีที่ใช้

| ส่วน | เทคโนโลยี |
|---|---|
| Framework | Flutter |
| ภาษา | Dart |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Local Storage | Shared Preferences, Flutter Secure Storage |
| REST API | http package |

## โครงสร้างโปรเจกต์

```
lib/
├── main.dart                 # จุดเริ่มต้นของแอป + Auth Gate
├── firebase_options.dart     # ค่าคอนฟิก Firebase ต่อแพลตฟอร์ม
├── models/                   # โครงสร้างข้อมูล (AppUser, CanteenTable)
├── services/                 # ตัวจัดการ logic (Auth, Firestore, API, Storage)
├── screens/                  # หน้าจอ UI (Login, Register, Home, Location, Profile)
└── widgets/                  # widget ย่อยที่ใช้ซ้ำ (TableCard, MenuOfTheDayCard)
```

## วิธีติดตั้งและรันโปรเจกต์

### 1. เตรียมเครื่องมือ

- ติดตั้ง [Flutter SDK](https://docs.flutter.dev/get-started/install)
- เช็คว่าติดตั้งครบด้วยคำสั่ง:
  ```bash
  flutter doctor
  ```

### 2. โคลนโปรเจกต์

```bash
git clone https://github.com/Chartkampoo/-Project-canteen.git
cd -Project-canteen
```

### 3. ติดตั้ง dependencies

```bash
flutter pub get
```

### 4. ตั้งค่า Firebase

โปรเจกต์นี้ใช้ Firebase (Authentication + Cloud Firestore) ต้องตั้งค่าไฟล์คอนฟิกก่อนรัน:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

คำสั่งนี้จะสร้าง/อัปเดต `lib/firebase_options.dart` และไฟล์คอนฟิกของแต่ละแพลตฟอร์ม (`google-services.json` สำหรับ Android, `GoogleService-Info.plist` สำหรับ iOS) ให้อัตโนมัติ โดยต้อง login บัญชี Firebase ที่มีสิทธิ์เข้าถึงโปรเจกต์ก่อน

> **หมายเหตุ:** ถ้าต้องการรันแบบเร็วที่สุดโดยไม่ตั้งค่า Firebase ใหม่ ให้รันเป็นเว็บแทน (ดูขั้นตอนที่ 5) เพราะค่าคอนฟิกฝั่ง web มีอยู่แล้วในโปรเจกต์

### 5. รันแอป

```bash
# รันบนเว็บ (เร็วที่สุด ไม่ต้องตั้งค่า Firebase เพิ่ม)
flutter run -d chrome

# หรือรันบน emulator / อุปกรณ์จริงที่เชื่อมต่ออยู่
flutter run
```

## Security Rules

โปรเจกต์นี้มี Firestore Security Rules อยู่ที่ `firestore.rules` — ก่อน deploy ใช้งานจริงควร deploy rules นี้ด้วยคำสั่ง:

```bash
firebase deploy --only firestore:rules
```

## ผู้พัฒนา

พัฒนาโดย [ชื่อ-นามสกุล] รหัสนักศึกษา [รหัส] สำหรับรายวิชา [ชื่อวิชา]
