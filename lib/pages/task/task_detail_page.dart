import 'package:flutter/material.dart';

class TaskDetailPage extends StatelessWidget {
  final String unitName;
  final String unitId;
  final String userRole;

  const TaskDetailPage({super.key, required this.unitName, required this.unitId, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Information")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(unitName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(unitId, style: const TextStyle(color: Colors.white38)),
            const Spacer(),
            if (userRole == "MECHANIC")
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9A825),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  child: const Text("UPDATE STATUS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            else
              const Center(child: Text("Mode View-Only (Operator)", style: TextStyle(color: Colors.white24))),
          ],
        ),
      ),
    );
  }
}