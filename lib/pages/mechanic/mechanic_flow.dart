import 'package:flutter/material.dart';

class MechanicTasksFlow extends StatelessWidget {
  const MechanicTasksFlow({super.key});
  @override
  Widget build(BuildContext context) {
    return const MechanicTasksPage();
  }
}

// --- SCREEN 1: TASKS LIST ---
class MechanicTasksPage extends StatelessWidget {
  const MechanicTasksPage({super.key});
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tasks = [
      {"unit": "Excavator EX-01", "id": "#MEC-001", "status": "Reported", "isDone": false},
      {"unit": "Excavator EX-02", "id": "#MEC-002", "status": "Finished", "isDone": true},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("TASKS", style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.bold))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final item = tasks[index];
          bool isDone = item['isDone'];
          return Opacity(
            opacity: isDone ? 0.5 : 1.0,
            child: Card(
              color: const Color(0xFF1E1E1E),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: isDone ? null : () => Navigator.push(context, MaterialPageRoute(builder: (c) => TaskDetailsPage(unit: item['unit'], id: item['id']))),
                title: Text(item['unit'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(item['status'], style: TextStyle(color: isDone ? Colors.green : Colors.orange)),
                trailing: isDone ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.arrow_forward_ios, size: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- SCREEN 2: DETAILS (READ-ONLY) ---
class TaskDetailsPage extends StatelessWidget {
  final String unit, id;
  const TaskDetailsPage({super.key, required this.unit, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(unit, style: const TextStyle(color: Color(0xFFF9A825), fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text("Report Details (Operator)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16), width: double.infinity,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
            child: const Text("Kebocoran oli pada selang hidrolik utama.", style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(height: 20),
          const Text("Mechanic Notes", style: TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const TextField(maxLines: 3, decoration: InputDecoration(hintText: "Add your findings...", filled: true, fillColor: Color(0xFF1E1E1E), border: OutlineInputBorder())),
        ]),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20), color: const Color(0xFF121212),
        child: SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => TaskUpdatePage(unit: unit, id: id))), child: const Text("TASK UPDATE", style: TextStyle(color: Colors.white)))),
      ),
    );
  }
}

// --- SCREEN 3: UPDATE (LOCKING LOGIC & PRINT) ---
class TaskUpdatePage extends StatefulWidget {
  final String unit, id;
  const TaskUpdatePage({super.key, required this.unit, required this.id});
  @override
  State<TaskUpdatePage> createState() => _TaskUpdatePageState();
}

class _TaskUpdatePageState extends State<TaskUpdatePage> {
  String selectedStatus = "Ongoing"; // Sistem Radio Button
  
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
    // Field hanya aktif jika "Finished" terpilih
    bool isFinished = selectedStatus == "Finished";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("Set Status & KPI")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Set unit status:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(children: [
            _btn("On Hold", Colors.white, Colors.red, selectedStatus == "On Hold"),
            const SizedBox(width: 8),
            _btn("Ongoing", const Color(0xFFF9A825), Colors.black, selectedStatus == "Ongoing"),
            const SizedBox(width: 8),
            _btn("Finished", Colors.green, Colors.black, selectedStatus == "Finished"),
          ]),
          
          const SizedBox(height: 30),
          const Divider(color: Colors.white10),
          Text("KPI Analytics", style: TextStyle(color: isFinished ? const Color(0xFFF9A825) : Colors.white24, fontWeight: FontWeight.bold)),
          if (!isFinished) const Text("*Select 'Finished' to unlock KPI fields", style: TextStyle(color: Colors.redAccent, fontSize: 10)),
          const SizedBox(height: 15),
          
          _input("Total Repair Time", _repairTime, isFinished),
          _input("Total Operational Time", _opTime, isFinished),
          _input("Number of Failures", _failures, isFinished),
          _input("Actual Operating Hours", _actualOp, isFinished),
          _input("Breakdown Hours", _breakdown, isFinished),
          
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: isFinished ? _calculateKPI : null, child: const Text("PREVIEW RESULTS"))),
          
          const SizedBox(height: 20),
          _resRow("MTTR:", "${mttr.toStringAsFixed(2)} hrs"),
          _resRow("MTBF:", "${mtbf.toStringAsFixed(2)} hrs"),
          _resRow("MA:", "${ma.toStringAsFixed(1)} %"),
          
          const SizedBox(height: 20),
          // TOMBOL CETAK LAPORAN
          if (isFinished) 
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Printing PDF Report..."))),
                icon: const Icon(Icons.print, size: 18),
                label: const Text("CETAK LAPORAN"),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24)),
              ),
            ),
          const SizedBox(height: 100),
        ]),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20), color: const Color(0xFF121212),
        child: SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF9A825)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Repair Updated!"), backgroundColor: Colors.green));
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("UPDATE REPAIR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _btn(String label, Color bg, Color txt, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          selectedStatus = label;
          if (!active) { mttr = 0; mtbf = 0; ma = 0; } // Reset jika pindah status
        }),
        child: Container(
          height: 50,
          decoration: BoxDecoration(color: active ? bg : Colors.white10, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(label, style: TextStyle(color: active ? txt : Colors.white38, fontWeight: FontWeight.bold, fontSize: 11))),
        ),
      ),
    );
  }

  Widget _input(String l, TextEditingController c, bool en) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(controller: c, enabled: en, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 13), decoration: InputDecoration(labelText: l, filled: true, fillColor: en ? Colors.white10 : Colors.black26, border: const OutlineInputBorder())),
  );

  Widget _resRow(String l, String v) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), Text(v, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF9A825)))]);
}