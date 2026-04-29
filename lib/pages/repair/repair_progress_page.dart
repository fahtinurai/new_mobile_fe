import 'package:flutter/material.dart';

// --- 1. HALAMAN DAFTAR MONITORING (OPERATOR) ---
class AnalyticsReportPage extends StatelessWidget {
  const AnalyticsReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "UNIT TRACKING",
          style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text("Live Monitoring Mode", style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 20),
          
          // Row ini sekarang bisa di-klik untuk melihat detail
          _buildClickableUnit(context, "Excavator EX-01", "Diagnosing", Colors.orange, [
            "Pengecekan selang hidrolik",
            "Analisis tekanan pompa utama",
            "Pengecekan kebocoran oli di swing motor"
          ]),
          _buildClickableUnit(context, "Dump Truck DT-05", "Repairing", Colors.blue, [
            "Penggantian filter oli",
            "Pembersihan injector"
          ]),
          _buildClickableUnit(context, "Bulldozer BZ-03", "On Hold", Colors.red, [
            "Menunggu sparepart (Main Seal) dari gudang"
          ]),
        ],
      ),
    );
  }

  // Widget List Unit yang bisa di-klik untuk ke Detail
  Widget _buildClickableUnit(BuildContext context, String unit, String status, Color color, List<String> jobs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Pindah ke halaman detail (VIEW ONLY)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UnitTrackingDetailPage(unit: unit, status: status, jobs: jobs, color: color),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(unit, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 2. HALAMAN DETAIL KERJAAN MEKANIK (VIEW ONLY) ---
class UnitTrackingDetailPage extends StatelessWidget {
  final String unit;
  final String status;
  final List<String> jobs;
  final Color color;

  const UnitTrackingDetailPage({
    super.key, 
    required this.unit, 
    required this.status, 
    required this.jobs,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("Unit Activity")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Unit & Status
            Text(unit, style: const TextStyle(color: Color(0xFFF9A825), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 40),
            const Text("MECHANIC ACTIVITIES:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),

            // Daftar kegiatan mekanik (VIEW ONLY)
            Expanded(
              child: ListView.builder(
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white24, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            jobs[index],
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // INFORMASI FOOTER (PENGGANTI TOMBOL UPDATE)
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.visibility, color: Colors.white24),
                  SizedBox(height: 10),
                  Text(
                    "VIEW ONLY MODE",
                    style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    "Operator tidak memiliki akses untuk mengubah status perbaikan.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white10, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}