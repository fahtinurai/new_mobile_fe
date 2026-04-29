import 'package:flutter/material.dart';

class MechanicHistoryPage extends StatefulWidget {
  const MechanicHistoryPage({super.key});

  @override
  State<MechanicHistoryPage> createState() => _MechanicHistoryPageState();
}

class _MechanicHistoryPageState extends State<MechanicHistoryPage> {
  final List<Map<String, dynamic>> historyData = [
    {
      "unitName": "Excavator EX-01", 
      "id": "MEC-001", 
      "status": "Reported", 
      "isFinished": false,
      "currentJob": ["Ganti Selang Hidrolik", "Tambah Oli 5L"]
    },
    {
      "unitName": "Excavator EX-02", 
      "id": "MEC-002", 
      "status": "Finished", 
      "isFinished": true,
      "currentJob": []
    },
  ];

  void _showUpdateForm(BuildContext context, String unitName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateStatusModal(unitName: unitName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Repair History", style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyData.length,
        itemBuilder: (context, index) {
          final item = historyData[index];
          bool isFinished = item['isFinished'];
          return Card(
            color: const Color(0xFF1E1E1E),
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  title: Text(item['unitName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(item['status'], style: TextStyle(color: isFinished ? Colors.green : Colors.orange)),
                  trailing: isFinished ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.pending_actions, color: Colors.orange),
                ),
                if (!isFinished) ...[
                  const Divider(color: Colors.white10, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Ongoing Repair Details:", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...(item['currentJob'] as List<String>).map((job) => Row(children: [
                          const Icon(Icons.build, size: 12, color: Color(0xFFF9A825)),
                          const SizedBox(width: 8),
                          Text(job, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        ])),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF9A825)),
                            onPressed: () => _showUpdateForm(context, item['unitName']),
                            child: const Text("UPDATE STATUS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGET MODAL FORM UPDATE (DENGAN LOGIKA KPI & RADIO) ---
class UpdateStatusModal extends StatefulWidget {
  final String unitName;
  const UpdateStatusModal({super.key, required this.unitName});

  @override
  State<UpdateStatusModal> createState() => _UpdateStatusModalState();
}

class _UpdateStatusModalState extends State<UpdateStatusModal> {
  String selectedStatus = "Ongoing"; // Radio Logic
  
  final _repairTime = TextEditingController();
  final _failures = TextEditingController();
  final _opTime = TextEditingController();
  final _actualOp = TextEditingController();
  final _breakdown = TextEditingController();

  double mttr = 0, mtbf = 0, ma = 0;

  void _calculateKPI() {
    setState(() {
      double rt = double.tryParse(_repairTime.text) ?? 0;
      double ot = double.tryParse(_opTime.text) ?? 0;
      double f = double.tryParse(_failures.text) ?? 1;
      double ao = double.tryParse(_actualOp.text) ?? 0;
      double bd = double.tryParse(_breakdown.text) ?? 0;

      mttr = rt / f;
      mtbf = ot / f;
      ma = (ao + bd) > 0 ? (ao / (ao + bd)) * 100 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isFinished = selectedStatus == "Finished";

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      decoration: const BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text("Update Status: ${widget.unitName}", style: const TextStyle(color: Color(0xFFF9A825), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // 1. SELECT STATUS (RADIO BUTTONS)
            const Text("Select Unit Status", style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            Row(children: [
              _statusBtn("On Hold", Colors.white, Colors.red, selectedStatus == "On Hold"),
              const SizedBox(width: 8),
              _statusBtn("Ongoing", const Color(0xFFF9A825), Colors.black, selectedStatus == "Ongoing"),
              const SizedBox(width: 8),
              _statusBtn("Finished", Colors.green, Colors.black, selectedStatus == "Finished"),
            ]),
            
            const SizedBox(height: 25),
            const Divider(color: Colors.white10),
            const SizedBox(height: 10),

            // 2. KPI ANALYTICS (HANYA AKTIF JIKA FINISHED)
            Text("KPI Analytics Calculation", style: TextStyle(color: isFinished ? const Color(0xFFF9A825) : Colors.white24, fontWeight: FontWeight.bold)),
            if (!isFinished) const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text("*Pilih 'Finished' untuk membuka input KPI", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 15),
            _input("Total Repair Time (Hours)", _repairTime, isFinished),
            _input("Total Operational Time (Hours)", _opTime, isFinished),
            _input("Number of Failures", _failures, isFinished),
            _input("Actual Operating Hours", _actualOp, isFinished),
            _input("Breakdown Hours", _breakdown, isFinished),

            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: isFinished ? _calculateKPI : null, child: const Text("PREVIEW KPI RESULTS"))),

            const SizedBox(height: 20),
            _resRow("MTTR:", "${mttr.toStringAsFixed(2)} hrs"),
            _resRow("MTBF:", "${mtbf.toStringAsFixed(2)} hrs"),
            _resRow("MA:", "${ma.toStringAsFixed(1)} %"),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF9A825), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil Update ke $selectedStatus!"), backgroundColor: Colors.green));
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("CONFIRM UPDATE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _statusBtn(String label, Color bg, Color txt, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedStatus = label),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: active ? bg : Colors.white10,
            borderRadius: BorderRadius.circular(8),
            border: (label == "On Hold" && active) ? Border.all(color: Colors.red, width: 2) : null,
          ),
          child: Center(child: Text(label, style: TextStyle(color: active ? txt : Colors.white38, fontWeight: FontWeight.bold, fontSize: 11))),
        ),
      ),
    );
  }

  Widget _input(String l, TextEditingController c, bool en) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: c, enabled: en, keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 13, color: en ? Colors.white : Colors.white24),
      decoration: InputDecoration(
        labelText: l, filled: true, fillColor: en ? Colors.white10 : Colors.black12,
        labelStyle: TextStyle(color: en ? Colors.white38 : Colors.white10),
        border: const OutlineInputBorder()
      ),
    ),
  );

  Widget _resRow(String l, String v) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(l, style: const TextStyle(color: Colors.white70)), 
    Text(v, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF9A825)))
  ]);
}