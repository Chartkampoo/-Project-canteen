// หัวข้อ 5: State Management (StreamBuilder ฟังข้อมูล real-time)
// หัวข้อ 7: Navigation and Routing (BottomNavigationBar สลับหน้า)
// หัวข้อ 8: Working with API (การ์ดเมนูแนะนำวันนี้)
// หน้าหลัก: แสดงรายการโต๊ะ + สถานะว่าง/ไม่ว่าง + ปุ่ม logout + ปุ่มเพิ่มโต๊ะ (เฉพาะแอดมิน)

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/table_card.dart';
import '../widgets/menu_of_the_day_card.dart';
import 'profile_screen.dart';
import 'location_screen.dart';
import '../models/canteen_table.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  int _currentIndex = 0;
  bool _isAdmin = false;

  late final List<Widget> _pages = [
    _TableListView(firestoreService: _firestoreService, authService: _authService),
    const LocationScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadAdminStatus();
  }

  Future<void> _loadAdminStatus() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    final profile = await _authService.fetchProfile(uid);
    if (mounted) {
      setState(() => _isAdmin = profile?.isAdmin ?? false);
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('ต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('ออกจากระบบ')),
        ],
      ),
    );
    if (shouldLogout == true) {
      await _authService.logout();
    }
  }

  Future<void> _showAddTableDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final capacityController = TextEditingController(text: '4');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('เพิ่มโต๊ะใหม่'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'ชื่อโต๊ะ เช่น โต๊ะ A1'),
                validator: (v) => (v == null || v.isEmpty) ? 'กรุณากรอกชื่อโต๊ะ' : null,
              ),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'สถานที่ เช่น โรงอาหารตึก 1 ชั้น 1'),
                validator: (v) => (v == null || v.isEmpty) ? 'กรุณากรอกสถานที่' : null,
              ),
              TextFormField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'จำนวนที่นั่ง'),
                validator: (v) =>
                    (v == null || int.tryParse(v) == null) ? 'กรอกเป็นตัวเลข' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newId = DateTime.now().millisecondsSinceEpoch.toString();
              await _firestoreService.addTable(CanteenTable(
                id: newId,
                name: nameController.text.trim(),
                location: locationController.text.trim(),
                capacity: int.parse(capacityController.text.trim()),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['จองโต๊ะอาหาร', 'สถานที่โรงอาหาร', 'ข้อมูลส่วนตัว'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ออกจากระบบ',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: _pages[_currentIndex],
      floatingActionButton: (_currentIndex == 0 && _isAdmin)
          ? FloatingActionButton(
              onPressed: () => _showAddTableDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.table_restaurant), label: 'จองโต๊ะ'),
          NavigationDestination(icon: Icon(Icons.location_on), label: 'สถานที่'),
          NavigationDestination(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }
}

class _TableListView extends StatefulWidget {
  final FirestoreService firestoreService;
  final AuthService authService;

  const _TableListView({required this.firestoreService, required this.authService});

  @override
  State<_TableListView> createState() => _TableListViewState();
}

class _TableListViewState extends State<_TableListView> {
  bool _showAvailableOnly = false;

  Future<void> _handleBook(BuildContext context, String tableId) async {
    final user = widget.authService.currentUser;
    if (user == null) return;

    final success = await widget.firestoreService.bookTable(
      tableId: tableId,
      uid: user.uid,
      userName: user.displayName ?? user.email ?? 'ผู้ใช้',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'จองโต๊ะสำเร็จ' : 'โต๊ะนี้เพิ่งถูกจองไปแล้ว')),
      );
    }
  }

  Future<void> _handleCancel(BuildContext context, String tableId) async {
    await widget.firestoreService.cancelBooking(tableId);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ยกเลิกการจองแล้ว')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = widget.authService.currentUser?.uid;

    return StreamBuilder(
      stream: widget.firestoreService.tablesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        final allTables = snapshot.data ?? [];
        final availableCount = allTables.where((t) => !t.isBooked).length;

        final sortedTables = [...allTables]
          ..sort((a, b) => a.isBooked == b.isBooked ? 0 : (a.isBooked ? 1 : -1));

        final displayedTables = _showAvailableOnly
            ? sortedTables.where((t) => !t.isBooked).toList()
            : sortedTables;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // การ์ดเมนูแนะนำวันนี้ (หัวข้อ 8: Working with API)
            const MenuOfTheDayCard(),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 12),
              color: Colors.green.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.event_seat, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ว่าง $availableCount จาก ${allTables.length} โต๊ะ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  FilterChip(
                    label: const Text('เฉพาะโต๊ะว่าง'),
                    selected: _showAvailableOnly,
                    onSelected: (value) => setState(() => _showAvailableOnly = value),
                  ),
                ],
              ),
            ),

            if (displayedTables.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('ไม่พบโต๊ะที่ตรงเงื่อนไข')),
              )
            else
              ...displayedTables.map((table) => TableCard(
                    table: table,
                    isMine: table.bookedByUid == myUid,
                    onBook: () => _handleBook(context, table.id),
                    onCancel: () => _handleCancel(context, table.id),
                  )),
          ],
        );
      },
    );
  }
}