import 'package:flutter/material.dart';

class OperatorDetailOnly extends StatelessWidget {
  final String unit;
  final String status;
  final Color color;
  final String info;

  const OperatorDetailOnly({
    super.key,
    required this.unit,
    required this.status,
    required this.color,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          unit,
          style: const TextStyle(
            color: Color(0xFFF9A825),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// STATUS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            /// INFO BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                info,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),

            const SizedBox(height: 30),

            /// DETAIL SECTION
            const Text(
              "Unit Detail",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            _buildDetailRow("Unit Name", unit),
            _buildDetailRow("Status", status),
            _buildDetailRow("Condition Info", info),

            const SizedBox(height: 30),

            /// ACTION BUTTON (dummy)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9A825),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "BACK",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white38)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
