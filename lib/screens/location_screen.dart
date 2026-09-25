// หัวข้อ 5: State Management Basics (Stateful vs Stateless ในหน้าเดียวกัน)
// หน้าสถานที่: แสดงโซนโรงอาหาร และกรองรายการโต๊ะตามโซนที่เลือก

import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/table_card.dart';
import '../services/auth_service.dart';

// รายชื่อโซนแบบ static ไว้ก่อน (โปรเจกต์จริงอาจดึงจาก Firestore เช่นกัน)
const List<Map<String, String>> canteenZones = [
  {'name': 'โรงอาหารตึก 1', 'floor': 'ชั้น 1'},
  {'name': 'โรงอาหารตึก 1', 'floor': 'ชั้น 2'},
  {'name': 'โรงอาหารตึก 2', 'floor': 'ชั้น 1'},
];

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? _selectedZone; // state: โซนที่ผู้ใช้เลือกดูอยู่ (null = ยังไม่เลือก)

  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    if (_selectedZone == null) {
      return _buildZoneList();
    }
    return _buildTablesInZone(_selectedZone!);
  }

  // แสดงรายชื่อโซนแบบ Stateless list (ListView.separated)
  Widget _buildZoneList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: canteenZones.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final zone = canteenZones[index];
        final zoneName = '${zone['name']} ${zone['floor']}';
        return Card(
          child: ListTile(
            leading: const Icon(Icons.location_on, color: Colors.deepOrange),
            title: Text(zoneName),
            subtitle: const Text('แตะเพื่อดูโต๊ะว่างในโซนนี้'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selectedZone = zoneName),
          ),
        );
      },
    );
  }

  // แสดงโต๊ะเฉพาะในโซนที่เลือก โดยดึงจาก Firestore แบบ filter
  Widget _buildTablesInZone(String zoneName) {
    final myUid = _authService.currentUser?.uid;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedZone = null),
              ),
              Expanded(
                child: Text(zoneName,
                    style:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: _firestoreService.tablesByLocation(zoneName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final tables = snapshot.data ?? [];
              if (tables.isEmpty) {
                return const Center(child: Text('ยังไม่มีโต๊ะในโซนนี้'));
              }
              return ListView.builder(
                itemCount: tables.length,
                itemBuilder: (context, index) {
                  final table = tables[index];
                  return TableCard(
                    table: table,
                    isMine: table.bookedByUid == myUid,
                    onBook: () => _firestoreService.bookTable(
                      tableId: table.id,
                      uid: myUid ?? '',
                      userName: _authService.currentUser?.displayName ?? 'ผู้ใช้',
                    ),
                    onCancel: () => _firestoreService.cancelBooking(table.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
