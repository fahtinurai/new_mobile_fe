import 'package:flutter/material.dart';

// -------------------------------------------------------------------
// 1. HALAMAN UTAMA: DAFTAR REPAIR STATUS (OPERATOR VIEW)
// -------------------------------------------------------------------
class RepairStatusPage extends StatelessWidget {
  const RepairStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "REPAIR STATUS", 
          style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.bold, letterSpacing: 1.2)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Tracking Unit Repair Progress",
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 20),
          
          // Data dummy untuk Operator
          _buildRepairCard(
            context, 
            "Excavator EX-01", 
            "In Progress", 
            Colors.blue,
            ["Pengecekan hidrolik", "Analisis kebocoran seal", "Proses pembersihan komponen"]
          ),
          _buildRepairCard(
            context, 
            "Dump Truck DT-05", 
            "Reported", 
            Colors.orange,
            ["Laporan masuk", "Menunggu ketersediaan mekanik"]
          ),
          _buildRepairCard(
            context, 
            "Bulldozer BZ-02", 
            "Waiting Parts", 
            Colors.redAccent,
            ["Identifikasi kerusakan Main Valve", "Pemesanan sparepart ke pusat", "Estimasi tiba: 14 April"]
          ),
        ],
      ),
    );
  }

  Widget _buildRepairCard(BuildContext context, String title, String status, Color color, List<String> logs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // Pindah ke halaman detail yang View Only
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RepairDetailViewOnly(
                unitName: title,
                status: status,
                statusColor: color,
                workLogs: logs,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// 2. HALAMAN DETAIL: REPAIR PROGRESS (VIEW ONLY - TANPA TOMBOL UPDATE)
// -------------------------------------------------------------------
class RepairDetailViewOnly extends StatelessWidget {
  final String unitName;
  final String status;
  final Color statusColor;
  final List<String> workLogs;

  const RepairDetailViewOnly({
    super.key,
    required this.unitName,
    required this.status,
    required this.statusColor,
    required this.workLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Unit Progress Detail"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Text(unitName, style: const TextStyle(color: Color(0xFFF9A825), fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status, 
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            
            const SizedBox(height: 40),
            const Text(
              "MECHANIC WORK LOGS:", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13)
            ),
            const SizedBox(height: 16),

            // Daftar Aktivitas (Hanya dibaca)
            Expanded(
              child: ListView.builder(
                itemCount: workLogs.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white24, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            workLogs[index],
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // FOOTER: AREA INFORMASI (HILANGKAN TOMBOL UPDATE STATUS)
            const Divider(color: Colors.white10, height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.visibility_off_outlined, color: Colors.white24, size: 24),
                  SizedBox(height: 12),
                  Text(
                    "VIEW ONLY MODE",
                    style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Operator tidak memiliki akses untuk mengubah data perbaikan unit ini.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white12, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}