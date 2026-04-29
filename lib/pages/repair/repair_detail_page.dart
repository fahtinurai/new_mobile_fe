import 'package:flutter/material.dart';

class TaskDetailPage extends StatelessWidget {
  final String unitName;
  final String unitId;
  final String userRole; // Tambahkan variabel untuk membedakan Role

  const TaskDetailPage({
    super.key, 
    this.unitName = "Unit", 
    this.unitId = "#ID",
    required this.userRole, // Role wajib diisi saat pindah halaman
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Detail Information", style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(unitName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(unitId, style: const TextStyle(color: Colors.white38)),
            const SizedBox(height: 30),
            
            // Info Row
            Row(
              children: [
                _buildInfoBox("DATE", "Oct 24, 2026"),
                const SizedBox(width: 16),
                _buildInfoBox("HOUR METER", "4,500 HRS"),
              ],
            ),
            
            const SizedBox(height: 30),
            const Text("DIAGNOSIS", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
              child: const Text(
                "Unit requires immediate attention on hydraulic systems.", 
                style: TextStyle(color: Colors.white70)
              ),
            ),

            const SizedBox(height: 30),

            // LOGIKA PEMBEDA: Hanya munculkan tombol jika role adalah MECHANIC
            if (userRole == "MECHANIC") 
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Logika update status mekanik
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9A825),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("UPDATE STATUS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            else 
              // Jika Operator, tampilkan teks info saja atau kosongkan
              const Center(
                child: Text(
                  "Viewing mode only (Operator)", 
                  style: TextStyle(color: Colors.white24, fontSize: 12, fontStyle: FontStyle.italic)
                )
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}