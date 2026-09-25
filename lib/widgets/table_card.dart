// หัวข้อ 4: Layout and Widget Tree
// การประกอบ widget หลายชั้น (Card > Padding > Row > Column ...) เป็น component ที่ใช้ซ้ำได้

import 'package:flutter/material.dart';
import '../models/canteen_table.dart';

class TableCard extends StatelessWidget {
  final CanteenTable table;
  final bool isMine; // โต๊ะนี้ผู้ใช้ปัจจุบันเป็นคนจองอยู่หรือไม่
  final VoidCallback onBook;
  final VoidCallback onCancel;

  const TableCard({
    super.key,
    required this.table,
    required this.isMine,
    required this.onBook,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        table.isBooked ? (isMine ? Colors.blue : Colors.red) : Colors.green;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ไอคอนสถานะด้านซ้าย
            CircleAvatar(
              radius: 24,
              backgroundColor: statusColor.withOpacity(0.15),
              child: Icon(Icons.table_restaurant, color: statusColor),
            ),
            const SizedBox(width: 14),

            // ข้อมูลตรงกลาง ขยายเต็มพื้นที่ที่เหลือ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(table.name,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(table.location, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 2),
                  Text('นั่งได้ ${table.capacity} ที่'),
                  if (table.isBooked)
                    Text(
                      isMine ? 'คุณจองโต๊ะนี้อยู่' : 'จองโดย ${table.bookedByName ?? "-"}',
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),

            // ปุ่มด้านขวา เปลี่ยนตามสถานะ
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (!table.isBooked) {
      return FilledButton(onPressed: onBook, child: const Text('จอง'));
    }
    if (isMine) {
      return OutlinedButton(onPressed: onCancel, child: const Text('ยกเลิก'));
    }
    return const Chip(label: Text('เต็ม'));
  }
}
