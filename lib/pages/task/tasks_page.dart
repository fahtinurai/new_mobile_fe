import 'package:flutter/material.dart';
import 'task_detail_page.dart'; 

class TasksPage extends StatelessWidget {
  final String userRole; // Menangkap role dari MainNavigation

  const TasksPage({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    // Data List Tugas sesuai gambar
    final List<Map<String, dynamic>> taskList = [
      {
        "unitName": "Excavator EX-01",
        "id": "#MEC-001",
        "status": "Reported",
        "isFinished": false,
      },
      {
        "unitName": "Excavator EX-02",
        "id": "#MEC-002",
        "status": "Finished",
        "isFinished": true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "TASKS",
          style: TextStyle(
            color: Color(0xFFF9A825), 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Karena ini tab utama
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: taskList.length,
        itemBuilder: (context, index) {
          final task = taskList[index];
          return _buildTaskCard(context, task);
        },
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task) {
    bool isFinished = task['isFinished'];

    // Desain Card Tugas
    Widget cardContent = Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          task['unitName'],
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task['id'], style: const TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              task['status'],
              style: TextStyle(
                color: isFinished ? Colors.green : Colors.orange, // Hijau jika selesai, Oranye jika lapor
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: isFinished
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
      ),
    );

    // LOGIKA KUNCI: Rendering Kondisional
    if (isFinished) {
      return Opacity(
        opacity: 0.5, // Efek pudar untuk yang sudah selesai
        child: cardContent, // Tanpa InkWell = Tidak bisa diklik
      );
    }

    // Jika belum selesai (Reported), bisa diklik
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(
              unitName: task['unitName'],
              unitId: task['id'],
              userRole: userRole,
            ),
          ),
        );
      },
      child: cardContent,
    );
  }
}