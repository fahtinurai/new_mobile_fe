import 'package:flutter/material.dart';
import 'package:djatimobile_project/pages/dashboard/operator_detail_only.dart';

class AnalyticsReportPage extends StatelessWidget {
  const AnalyticsReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "UNIT ANALYTICS",
          style: TextStyle(
            color: Color(0xFFF9A825),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- BAGIAN HM, FUEL, & SERVICE (VIEW ONLY) ---
            const Text(
              "Fleet Performance Overview",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    "Total HM",
                    "1,240 hrs",
                    Icons.timer,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    "Avg Fuel",
                    "18.5 L/h",
                    Icons.local_gas_station,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildWideInfoCard(
              "Annual Service",
              "8 Times Completed",
              Icons.build_circle,
              Colors.green,
            ),

            const SizedBox(height: 32),
            const Divider(color: Colors.white10),
            const SizedBox(height: 24),

            /// --- BAGIAN UNIT TRACKING ---
            const Text(
              "Unit Progress Tracking",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _buildTrackingRow(
              context,
              "Excavator EX-01",
              "Diagnosing",
              Colors.orange,
              "HM: 450 hrs | Fuel: 12 L/h",
            ),

            _buildTrackingRow(
              context,
              "Dump Truck DT-05",
              "Repairing",
              Colors.blue,
              "HM: 890 hrs | Fuel: 25 L/h",
            ),

            _buildTrackingRow(
              context,
              "Bulldozer BZ-03",
              "On Hold",
              Colors.red,
              "HM: 320 hrs | Fuel: 20 L/h",
            ),
          ],
        ),
      ),
    );
  }

  /// Widget kartu kecil
  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget kartu lebar
  Widget _buildWideInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget tracking row
  Widget _buildTrackingRow(
    BuildContext context,
    String unit,
    String status,
    Color color,
    String info,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OperatorDetailOnly(
                unit: unit,
                status: status,
                color: color,
                info: info,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    info,
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}