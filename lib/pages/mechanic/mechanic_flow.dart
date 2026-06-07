import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:djatimobile_project/core/services/auth_service.dart';
import 'package:djatimobile_project/core/services/technician_part_usage_service.dart';

class MechanicTasksFlow extends StatelessWidget {
  const MechanicTasksFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const MechanicTasksPage();
  }
}

// -------------------------------------------------------------------
// SCREEN 1: TASKS LIST DARI SERVICE BOOKINGS UNTUK TEKNISI
// -------------------------------------------------------------------
class MechanicTasksPage extends StatefulWidget {
  const MechanicTasksPage({super.key});

  @override
  State<MechanicTasksPage> createState() => _MechanicTasksPageState();
}

class _MechanicTasksPageState extends State<MechanicTasksPage> {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _jobs = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  dynamic _safeJsonDecode(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  List<dynamic> _parseJobList(String body) {
    final decoded = _safeJsonDecode(body);

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final data = decoded["data"];

      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        final nestedData = data["data"];

        if (nestedData is List) {
          return nestedData;
        }
      }

      final jobs = decoded["jobs"];
      if (jobs is List) {
        return jobs;
      }

      final serviceJobs = decoded["service_jobs"];
      if (serviceJobs is List) {
        return serviceJobs;
      }

      final bookings = decoded["bookings"];
      if (bookings is List) {
        return bookings;
      }
    }

    if (decoded is Map) {
      final mapped = Map<String, dynamic>.from(decoded);
      final data = mapped["data"];

      if (data is List) {
        return data;
      }

      if (data is Map) {
        final nestedData = data["data"];

        if (nestedData is List) {
          return nestedData;
        }
      }
    }

    return [];
  }

  String _errorFromResponse(http.Response response, String fallback) {
    final decoded = _safeJsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final message = decoded["message"]?.toString();

      if (message != null && message.isNotEmpty) {
        return message;
      }

      final errors = decoded["errors"];

      if (errors is Map && errors.isNotEmpty) {
        final firstValue = errors.values.first;

        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }

        return firstValue.toString();
      }
    }

    return "$fallback. Status: ${response.statusCode}";
  }

  Future<void> _loadTasks() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/technician/service-jobs?status=active"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint("MECHANIC JOB STATUS: ${response.statusCode}");
      debugPrint("MECHANIC JOB BODY: ${response.body}");

      if (response.statusCode == 200) {
        final jobs = _parseJobList(response.body);

        if (!mounted) return;

        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      } else {
        throw Exception(
          _errorFromResponse(
            response,
            "Gagal mengambil job teknisi",
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  Map<String, dynamic>? _getDamageReport(Map<String, dynamic> job) {
    return _asMap(job["damage_report"]);
  }

  Map<String, dynamic>? _getVehicle(Map<String, dynamic> job) {
    final directVehicle = _asMap(job["vehicle"]);
    if (directVehicle != null) {
      return directVehicle;
    }

    final report = _getDamageReport(job);
    return _asMap(report?["vehicle"]);
  }

  Map<String, dynamic>? _getDriver(Map<String, dynamic> job) {
    final directDriver = _asMap(job["driver"]);
    if (directDriver != null) {
      return directDriver;
    }

    final report = _getDamageReport(job);
    return _asMap(report?["driver"]);
  }

  String _getUnitName(Map<String, dynamic> job) {
    final vehicle = _getVehicle(job);

    if (vehicle != null) {
      return vehicle["equipment_name"]?.toString() ??
          vehicle["name"]?.toString() ??
          "Unknown Unit";
    }

    return "Unknown Unit";
  }

  String _getPlateNumber(Map<String, dynamic> job) {
    final vehicle = _getVehicle(job);

    if (vehicle != null) {
      return vehicle["plate_number"]?.toString() ?? "-";
    }

    return "-";
  }

  String _getDriverName(Map<String, dynamic> job) {
    final driver = _getDriver(job);

    if (driver == null) {
      return "Unknown Driver";
    }

    return driver["name"]?.toString() ??
        driver["username"]?.toString() ??
        "Unknown Driver";
  }

  String _getDamageType(Map<String, dynamic> job) {
    final report = _getDamageReport(job);

    return report?["damage_type"]?.toString() ??
        job["damage_type"]?.toString() ??
        "-";
  }

  String _getDescription(Map<String, dynamic> job) {
    final report = _getDamageReport(job);

    return report?["description"]?.toString() ??
        job["description"]?.toString() ??
        "-";
  }

  String _formatDateTime(dynamic value) {
    final raw = value?.toString();

    if (raw == null || raw.isEmpty || raw == "null") {
      return "-";
    }

    try {
      final date = DateTime.parse(raw).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return "$day-$month-$year $hour:$minute WIB";
    } catch (_) {
      return raw;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case "approved":
      case "scheduled":
        return "Ready to Start";

      case "rescheduled":
        return "Rescheduled";

      case "in_progress":
        return "In Progress";

      case "completed":
        return "Completed";

      case "canceled":
      case "cancelled":
        return "Canceled";

      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
      case "scheduled":
        return Colors.lightBlueAccent;

      case "rescheduled":
        return Colors.purpleAccent;

      case "in_progress":
        return Colors.amber;

      case "completed":
        return Colors.green;

      case "canceled":
      case "cancelled":
        return Colors.redAccent;

      default:
        return Colors.white54;
    }
  }

  bool _isDone(String status) {
    final lower = status.toLowerCase();

    return lower == "completed" ||
        lower == "canceled" ||
        lower == "cancelled";
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF9A825),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadTasks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9A825),
                ),
                child: const Text(
                  "Coba Lagi",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_jobs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadTasks,
        color: const Color(0xFFF9A825),
        backgroundColor: const Color(0xFF1E1E1E),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 120),
            Icon(
              Icons.assignment_outlined,
              color: Colors.white24,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              "Belum ada job maintenance untuk teknisi.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
            SizedBox(height: 8),
            Text(
              "Job akan muncul setelah admin approve dan menjadwalkan teknisi.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white24,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    final mappedJobs = _jobs
        .map((item) => _asMap(item))
        .whereType<Map<String, dynamic>>()
        .toList();

    return RefreshIndicator(
      onRefresh: _loadTasks,
      color: const Color(0xFFF9A825),
      backgroundColor: const Color(0xFF1E1E1E),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Technician Maintenance Jobs",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Mulai pekerjaan saat tiba di unit, lalu selesaikan setelah maintenance selesai.",
            style: TextStyle(
              color: Colors.white24,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...mappedJobs.map<Widget>((job) {
            final bookingId = job["id"]?.toString() ?? "-";
            final reportId = job["damage_report_id"]?.toString() ??
                _getDamageReport(job)?["id"]?.toString() ??
                "-";

            final unit = _getUnitName(job);
            final plate = _getPlateNumber(job);
            final driver = _getDriverName(job);

            final status = job["status"]?.toString() ?? "approved";
            final statusLabel = _getStatusLabel(status);
            final statusColor = _getStatusColor(status);
            final isDone = _isDone(status);

            final scheduledAt = _formatDateTime(job["scheduled_at"]);
            final estimatedFinishAt =
                _formatDateTime(job["estimated_finish_at"]);

            return Opacity(
              opacity: isDone ? 0.55 : 1.0,
              child: Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: statusColor.withValues(alpha: 0.35),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsPage(
                          job: job,
                        ),
                      ),
                    );

                    if (!mounted) return;

                    if (result == true) {
                      await _loadTasks();
                    }
                  },
                  title: Text(
                    unit,
                    style: const TextStyle(
                      color: Color(0xFFF9A825),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "#BK-$bookingId | #DR-$reportId",
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Plate: $plate",
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Driver: $driver",
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          scheduledAt == "-"
                              ? "Schedule: belum tersedia"
                              : "Schedule: $scheduledAt",
                          style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          estimatedFinishAt == "-"
                              ? "Est. Finish: -"
                              : "Est. Finish: $estimatedFinishAt",
                          style: const TextStyle(
                            color: Colors.white30,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: isDone
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        )
                      : const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white24,
                          size: 14,
                        ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "TASKS",
          style: TextStyle(
            color: Color(0xFFF9A825),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }
}

// -------------------------------------------------------------------
// SCREEN 2: DETAILS SERVICE JOB TEKNISI
// -------------------------------------------------------------------
class TaskDetailsPage extends StatefulWidget {
  final Map<String, dynamic> job;

  const TaskDetailsPage({
    super.key,
    required this.job,
  });

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  Map<String, dynamic> get job => widget.job;

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  Map<String, dynamic>? _getDamageReport() {
    return _asMap(job["damage_report"]);
  }

  Map<String, dynamic>? _getVehicle() {
    final directVehicle = _asMap(job["vehicle"]);
    if (directVehicle != null) {
      return directVehicle;
    }

    final report = _getDamageReport();
    return _asMap(report?["vehicle"]);
  }

  Map<String, dynamic>? _getDriver() {
    final directDriver = _asMap(job["driver"]);
    if (directDriver != null) {
      return directDriver;
    }

    final report = _getDamageReport();
    return _asMap(report?["driver"]);
  }

  int? _getDamageReportId() {
    final report = _getDamageReport();

    final rawId =
        job["damage_report_id"] ??
        job["damageReportId"] ??
        report?["id"];

    return int.tryParse(rawId?.toString() ?? "");
  }

  String _getUnitName() {
    final vehicle = _getVehicle();

    if (vehicle != null) {
      return vehicle["equipment_name"]?.toString() ??
          vehicle["name"]?.toString() ??
          "Unknown Unit";
    }

    return "Unknown Unit";
  }

  String _getPlateNumber() {
    final vehicle = _getVehicle();

    if (vehicle != null) {
      return vehicle["plate_number"]?.toString() ?? "-";
    }

    return "-";
  }

  String _getDamageType() {
    final report = _getDamageReport();

    return report?["damage_type"]?.toString() ??
        job["damage_type"]?.toString() ??
        "-";
  }

  String _getDescription() {
    final report = _getDamageReport();

    return report?["description"]?.toString() ??
        job["description"]?.toString() ??
        "-";
  }

  String? _normalizeDamageImageUrl(dynamic value) {
    final raw = value?.toString().trim();

    if (raw == null || raw.isEmpty || raw == "null") {
      return null;
    }

    if (raw.startsWith("http://") || raw.startsWith("https://")) {
      return raw;
    }

    var path = raw.replaceAll("\\", "/");

    if (path.startsWith("/storage/")) {
      return "http://10.0.2.2:8000$path";
    }

    if (path.startsWith("storage/")) {
      return "http://10.0.2.2:8000/$path";
    }

    if (path.startsWith("public/")) {
      path = path.replaceFirst("public/", "");
    }

    if (path.startsWith("/")) {
      path = path.substring(1);
    }

    return "http://10.0.2.2:8000/storage/$path";
  }

  String? _getDamageImageUrl() {
    final report = _getDamageReport();

    final rawImage = report?["image_url"] ??
        report?["photo_url"] ??
        report?["damage_image_url"] ??
        report?["image"] ??
        report?["image_path"] ??
        report?["photo"] ??
        report?["damage_photo"] ??
        report?["picture"] ??
        report?["file_path"] ??
        job["image_url"] ??
        job["photo_url"] ??
        job["damage_image_url"] ??
        job["image"] ??
        job["image_path"] ??
        job["photo"] ??
        job["damage_photo"] ??
        job["picture"] ??
        job["file_path"];

    return _normalizeDamageImageUrl(rawImage);
  }

  void _openDamageImagePreview(String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Center(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          "Gambar tidak dapat dimuat.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDriverName() {
    final driver = _getDriver();

    if (driver == null) {
      return "Unknown Driver";
    }

    return driver["name"]?.toString() ??
        driver["username"]?.toString() ??
        "Unknown Driver";
  }

  String _formatDate(dynamic value) {
    final raw = value?.toString();

    if (raw == null || raw.isEmpty || raw == "null") {
      return "-";
    }

    try {
      final date = DateTime.parse(raw).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return "$day-$month-$year $hour:$minute WIB";
    } catch (_) {
      return raw;
    }
  }

  String _getStatus() {
    final status = job["status"]?.toString() ?? "approved";

    switch (status.toLowerCase()) {
      case "approved":
      case "scheduled":
        return "Ready to Start";

      case "rescheduled":
        return "Rescheduled";

      case "in_progress":
        return "In Progress";

      case "completed":
        return "Completed";

      case "canceled":
      case "cancelled":
        return "Canceled";

      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "ready to start":
        return Colors.lightBlueAccent;

      case "rescheduled":
        return Colors.purpleAccent;

      case "in progress":
        return Colors.amber;

      case "completed":
        return Colors.green;

      case "canceled":
      case "cancelled":
        return Colors.redAccent;

      default:
        return Colors.white54;
    }
  }

  bool _canStart() {
    final status = job["status"]?.toString().toLowerCase() ?? "";

    return status == "approved" ||
        status == "scheduled" ||
        status == "rescheduled";
  }

  bool _canComplete() {
    final status = job["status"]?.toString().toLowerCase() ?? "";

    return status == "in_progress";
  }

  bool _isClosed() {
    final status = job["status"]?.toString().toLowerCase() ?? "";

    return status == "completed" ||
        status == "finished" ||
        status == "selesai" ||
        status == "canceled" ||
        status == "cancelled" ||
        status == "dibatalkan";
  }

  bool _canRequestSparepart() {
    final damageReportId = _getDamageReportId();
    final status = job["status"]?.toString().toLowerCase() ?? "";

    // Sparepart hanya boleh diminta setelah teknisi benar-benar mulai job.
    return status == "in_progress" &&
        damageReportId != null &&
        damageReportId > 0;
  }

  String _getActionText() {
    if (_canStart()) {
      return "START JOB";
    }

    if (_canComplete()) {
      return "COMPLETE JOB";
    }

    if (_isClosed()) {
      return "TASK CLOSED";
    }

    return "NO ACTION AVAILABLE";
  }

  Future<void> _goToActionPage() async {
    if (_isClosed()) {
      return;
    }

    if (!_canStart() && !_canComplete()) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Status job belum bisa diproses."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskUpdatePage(
          job: job,
          action: _canStart()
              ? TechnicianJobAction.start
              : TechnicianJobAction.complete,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _openPartRequestModal() async {
    final damageReportId = _getDamageReportId();

    if (damageReportId == null || damageReportId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Damage report ID tidak valid."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RequestPartUsageModal(
          damageReportId: damageReportId,
          unitName: _getUnitName(),
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request sparepart berhasil dikirim ke admin."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = _getUnitName();
    final plate = _getPlateNumber();
    final status = _getStatus();
    final statusColor = _getStatusColor(status);

    final bookingId = job["id"]?.toString() ?? "-";
    final reportId =
        job["damage_report_id"]?.toString() ??
        _getDamageReport()?["id"]?.toString() ??
        "-";

    final canRequestSparepart = _canRequestSparepart();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "Task Details",
          style: TextStyle(
            color: Color(0xFFF9A825),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unit,
              style: const TextStyle(
                color: Color(0xFFF9A825),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Plate Number: $plate",
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "#BK-$bookingId  •  #DR-$reportId",
              style: const TextStyle(
                color: Colors.white30,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.25)),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle("Report Details"),
            const SizedBox(height: 10),

            _infoBox(
              children: [
                _infoRow("Driver", _getDriverName()),
                _infoRow("Damage Type", _getDamageType()),
                _infoRow(
                  "Reported At",
                  _formatDate(_getDamageReport()?["created_at"]),
                ),
                _infoRow("Scheduled At", _formatDate(job["scheduled_at"])),
                _infoRow(
                  "Est. Finish",
                  _formatDate(job["estimated_finish_at"]),
                ),
                _infoRow("Started At", _formatDate(job["started_at"])),
                _infoRow("Completed At", _formatDate(job["completed_at"])),
                _infoRow("Priority", job["priority"]?.toString() ?? "-"),
                const SizedBox(height: 12),
                const Text(
                  "Description",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getDescription(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                _buildDamageImageSection(),
              ],
            ),

            const SizedBox(height: 24),

            _sectionTitle("Notes"),
            const SizedBox(height: 10),

            _noteBox("Driver Note", job["note_driver"]?.toString() ?? "-"),
            const SizedBox(height: 10),
            _noteBox("Admin Note", job["note_admin"]?.toString() ?? "-"),
            const SizedBox(height: 10),
            _noteBox(
              "Technician Note",
              job["note_technician"]?.toString() ?? "-",
            ),

            const SizedBox(height: 24),

            _sectionTitle("Technician Tools"),
            const SizedBox(height: 10),

            _infoBox(
              children: [
                Text(
                  canRequestSparepart
                      ? "Cari dan request sparepart yang dibutuhkan selama pekerjaan sedang berlangsung."
                      : "Request sparepart hanya tersedia setelah job dimulai oleh teknisi.",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton.icon(
                    onPressed:
                        canRequestSparepart ? _openPartRequestModal : null,
                    icon: const Icon(Icons.inventory_2_outlined, size: 18),
                    label: const Text("REQUEST SPAREPART"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF9A825),
                      disabledForegroundColor: Colors.white24,
                      side: BorderSide(
                        color: canRequestSparepart
                            ? const Color(0xFFF9A825)
                            : Colors.white12,
                      ),
                    ),
                  ),
                ),
                if (!canRequestSparepart) ...[
                  const SizedBox(height: 10),
                  const Text(
                    "Klik START JOB terlebih dahulu. Setelah status menjadi In Progress, teknisi baru bisa request sparepart.",
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF121212),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isClosed() ? Colors.white12 : const Color(0xFFF9A825),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isClosed() ? null : _goToActionPage,
            child: Text(
              _getActionText(),
              style: TextStyle(
                color: _isClosed() ? Colors.white38 : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _infoBox({
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDamageImageSection() {
    final imageUrl = _getDamageImageUrl();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Damage Photo",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        if (imageUrl == null)
          Container(
            width: double.infinity,
            height: 150,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: const Text(
              "Foto kerusakan belum tersedia.",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          )
        else
          GestureDetector(
            onTap: () => _openDamageImagePreview(imageUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return Container(
                        width: double.infinity,
                        height: 190,
                        alignment: Alignment.center,
                        color: Colors.white.withValues(alpha: 0.04),
                        child: const CircularProgressIndicator(
                          color: Color(0xFFF9A825),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 150,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: const Text(
                          "Gambar tidak dapat dimuat.",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Tap to view",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _noteBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// SCREEN 3: START / COMPLETE SERVICE JOB
// -------------------------------------------------------------------
enum TechnicianJobAction {
  start,
  complete,
}

class TaskUpdatePage extends StatefulWidget {
  final Map<String, dynamic> job;
  final TechnicianJobAction action;

  const TaskUpdatePage({
    super.key,
    required this.job,
    required this.action,
  });

  @override
  State<TaskUpdatePage> createState() => _TaskUpdatePageState();
}

class _TaskUpdatePageState extends State<TaskUpdatePage> {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  final TextEditingController _noteController = TextEditingController();

  final TextEditingController _repairTime = TextEditingController();
  final TextEditingController _failures = TextEditingController();
  final TextEditingController _opTime = TextEditingController();
  final TextEditingController _actualOp = TextEditingController();
  final TextEditingController _breakdown = TextEditingController();

  bool _isSubmitting = false;

  double mttr = 0;
  double mtbf = 0;
  double ma = 0;

  bool get _isStartAction => widget.action == TechnicianJobAction.start;

  bool get _isCompleteAction => widget.action == TechnicianJobAction.complete;

  @override
  void dispose() {
    _noteController.dispose();
    _repairTime.dispose();
    _failures.dispose();
    _opTime.dispose();
    _actualOp.dispose();
    _breakdown.dispose();
    super.dispose();
  }

  dynamic _safeJsonDecode(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _errorFromResponse(http.Response response, String fallback) {
    final decoded = _safeJsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final message = decoded["message"]?.toString();

      if (message != null && message.isNotEmpty) {
        return message;
      }

      final errors = decoded["errors"];

      if (errors is Map && errors.isNotEmpty) {
        final firstValue = errors.values.first;

        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }

        return firstValue.toString();
      }
    }

    return "$fallback. Status: ${response.statusCode}";
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  Map<String, dynamic>? _getDamageReport() {
    return _asMap(widget.job["damage_report"]);
  }

  Map<String, dynamic>? _getVehicle() {
    final directVehicle = _asMap(widget.job["vehicle"]);
    if (directVehicle != null) {
      return directVehicle;
    }

    final report = _getDamageReport();
    return _asMap(report?["vehicle"]);
  }

  String _unitName() {
    final vehicle = _getVehicle();

    if (vehicle != null) {
      return vehicle["equipment_name"]?.toString() ??
          vehicle["name"]?.toString() ??
          "Unknown Unit";
    }

    return "Unknown Unit";
  }

  void _calculateKPI() {
    if (!mounted) return;

    setState(() {
      final rt = double.tryParse(_repairTime.text) ?? 0;
      final ot = double.tryParse(_opTime.text) ?? 0;
      final f = double.tryParse(_failures.text) ?? 1;
      final ao = double.tryParse(_actualOp.text) ?? 0;
      final bd = double.tryParse(_breakdown.text) ?? 0;

      mttr = f > 0 ? rt / f : 0;
      mtbf = f > 0 ? ot / f : 0;
      ma = (ao + bd) > 0 ? (ao / (ao + bd)) * 100 : 0;
    });
  }

  Future<void> _submitJobAction() async {
    if (_isSubmitting) return;

    if (!mounted) return;

    setState(() => _isSubmitting = true);

    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      final bookingId = widget.job["id"]?.toString();

      if (bookingId == null || bookingId.isEmpty || bookingId == "null") {
        throw Exception("Booking ID tidak valid.");
      }

      if (_isCompleteAction) {
        final rt = double.tryParse(_repairTime.text) ?? 0;
        final ot = double.tryParse(_opTime.text) ?? 0;
        final f = double.tryParse(_failures.text) ?? 1;
        final ao = double.tryParse(_actualOp.text) ?? 0;
        final bd = double.tryParse(_breakdown.text) ?? 0;

        mttr = f > 0 ? rt / f : 0;
        mtbf = f > 0 ? ot / f : 0;
        ma = (ao + bd) > 0 ? (ao / (ao + bd)) * 100 : 0;
      }

      final endpoint = _isStartAction
          ? "$baseUrl/technician/service-jobs/$bookingId/start"
          : "$baseUrl/technician/service-jobs/$bookingId/complete";

      final body = <String, String>{};

      if (_noteController.text.trim().isNotEmpty) {
        body["note_technician"] = _noteController.text.trim();
      }

      if (_isCompleteAction) {
        body["mttr"] = mttr.toStringAsFixed(2);
        body["mtbf"] = mtbf.toStringAsFixed(2);
        body["ma"] = ma.toStringAsFixed(1);
      }

      debugPrint("JOB ACTION URL: $endpoint");
      debugPrint("JOB ACTION BODY: $body");

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body,
      );

      debugPrint("JOB ACTION STATUS: ${response.statusCode}");
      debugPrint("JOB ACTION BODY: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isStartAction
                  ? "Job berhasil dimulai."
                  : "Job berhasil diselesaikan.",
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception(
          _errorFromResponse(
            response,
            "Gagal update job",
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isStartAction ? "Start Job" : "Complete Job";
    final subtitle = _isStartAction
        ? "Teknisi akan memulai pekerjaan. Driver akan menerima notifikasi servis dimulai."
        : "Teknisi akan menyelesaikan pekerjaan. Driver akan menerima notifikasi servis selesai.";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFF9A825),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _unitName(),
              style: const TextStyle(
                color: Color(0xFFF9A825),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: _isStartAction
                    ? "Catatan awal teknisi"
                    : "Catatan penyelesaian teknisi",
                hintText: _isStartAction
                    ? "Contoh: Mulai pengecekan unit..."
                    : "Contoh: Oli sudah diganti, unit normal kembali...",
                labelStyle: const TextStyle(color: Colors.white38),
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: const OutlineInputBorder(),
              ),
            ),
            if (_isCompleteAction) ...[
              const SizedBox(height: 30),
              const Divider(color: Colors.white10),
              const Text(
                "KPI Analytics",
                style: TextStyle(
                  color: Color(0xFFF9A825),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Opsional. Isi data KPI jika pekerjaan sudah selesai.",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 15),
              _input("Total Repair Time", _repairTime),
              _input("Total Operational Time", _opTime),
              _input("Number of Failures", _failures),
              _input("Actual Operating Hours", _actualOp),
              _input("Breakdown Hours", _breakdown),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateKPI,
                  child: const Text("PREVIEW RESULTS"),
                ),
              ),
              const SizedBox(height: 20),
              _resRow("MTTR:", "${mttr.toStringAsFixed(2)} hrs"),
              const SizedBox(height: 8),
              _resRow("MTBF:", "${mtbf.toStringAsFixed(2)} hrs"),
              const SizedBox(height: 8),
              _resRow("MA:", "${ma.toStringAsFixed(1)} %"),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Fitur cetak laporan bisa disambungkan nanti.",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text("CETAK LAPORAN"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF121212),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isStartAction
                  ? Colors.lightBlueAccent
                  : const Color(0xFFF9A825),
            ),
            onPressed: _isSubmitting ? null : _submitJobAction,
            child: _isSubmitting
                ? const CircularProgressIndicator(
                    color: Colors.black,
                  )
                : Text(
                    _isStartAction ? "START SERVICE" : "COMPLETE SERVICE",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white10,
          labelStyle: const TextStyle(
            color: Colors.white38,
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _resRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFF9A825),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------
// MODAL: REQUEST SPAREPART TEKNISI
// -------------------------------------------------------------------
class RequestPartUsageModal extends StatefulWidget {
  final int damageReportId;
  final String unitName;

  const RequestPartUsageModal({
    super.key,
    required this.damageReportId,
    required this.unitName,
  });

  @override
  State<RequestPartUsageModal> createState() => _RequestPartUsageModalState();
}

class _RequestPartUsageModalState extends State<RequestPartUsageModal> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: "1");
  final TextEditingController _noteController = TextEditingController();

  Timer? _searchDebounce;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<dynamic> _parts = [];
  int? _selectedPartId;

  @override
  void initState() {
    super.initState();
    _loadParts();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  Map<String, dynamic>? _selectedPart() {
    if (_selectedPartId == null) {
      return null;
    }

    for (final item in _parts) {
      final part = _asMap(item);
      if (part == null) continue;

      final id = int.tryParse(part["id"]?.toString() ?? "") ?? 0;

      if (id == _selectedPartId) {
        return part;
      }
    }

    return null;
  }

  Future<void> _loadParts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final parts = await TechnicianPartUsageService.getParts(
        search: _searchController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _parts = parts;

        final selectedStillExists = _selectedPartId != null &&
            _parts
                .map((item) => _asMap(item))
                .whereType<Map<String, dynamic>>()
                .any((part) {
              final id =
                  int.tryParse(part["id"]?.toString() ?? "") ?? 0;
              return id == _selectedPartId;
            });

        if (!selectedStillExists) {
          _selectedPartId = null;
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _parts = [];
        _selectedPartId = null;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () {
        _loadParts();
      },
    );
  }

  int _getStock(Map<String, dynamic>? part) {
    if (part == null) return 0;

    return int.tryParse(part["stock"]?.toString() ?? "0") ?? 0;
  }

  String _getPartName(Map<String, dynamic>? part) {
    if (part == null) return "-";

    return part["name"]?.toString() ?? "-";
  }

  String _getPartSku(Map<String, dynamic>? part) {
    if (part == null) return "-";

    return part["sku"]?.toString() ?? "-";
  }

  Future<void> _submitRequest() async {
    if (_isSubmitting) return;

    final partId = _selectedPartId;
    final selectedPart = _selectedPart();
    final stock = _getStock(selectedPart);
    final qty = int.tryParse(_qtyController.text.trim()) ?? 0;

    if (partId == null || partId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih sparepart terlebih dahulu."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (qty < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Qty minimal 1."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Stok sparepart ini sedang kosong."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (qty > stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Qty melebihi stok tersedia. Stok saat ini: $stock."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await TechnicianPartUsageService.requestPartUsage(
        partId: partId,
        damageReportId: widget.damageReportId,
        qty: qty,
        note: _noteController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.white),
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        labelText: "Search sparepart",
        hintText: "Cari nama part atau SKU...",
        labelStyle: const TextStyle(color: Colors.white38),
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.white38,
        ),
        suffixIcon: _searchController.text.trim().isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  _loadParts();
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.white38,
                ),
              ),
        filled: true,
        fillColor: Colors.white10,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPartPicker() {
    if (_isLoading) {
      return const SizedBox(
        height: 170,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF9A825),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.redAccent.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          _errorMessage!,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      );
    }

    final mappedParts = _parts
        .map((item) => _asMap(item))
        .whereType<Map<String, dynamic>>()
        .toList();

    if (mappedParts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: const Text(
          "Sparepart tidak ditemukan. Coba kata kunci lain.",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 260,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: mappedParts.length,
        itemBuilder: (context, index) {
          final part = mappedParts[index];

          final id = int.tryParse(part["id"]?.toString() ?? "") ?? 0;
          final sku = _getPartSku(part);
          final name = _getPartName(part);
          final stock = _getStock(part);
          final isSelected = _selectedPartId == id;
          final isEmptyStock = stock <= 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFF9A825).withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFF9A825)
                    : Colors.white12,
              ),
            ),
            child: ListTile(
              enabled: !isEmptyStock,
              onTap: isEmptyStock
                  ? null
                  : () {
                      setState(() {
                        _selectedPartId = id;
                      });
                    },
              title: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isEmptyStock ? Colors.white30 : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "SKU: $sku • Stok: $stock",
                  style: TextStyle(
                    color: isEmptyStock ? Colors.redAccent : Colors.white54,
                    fontSize: 11,
                  ),
                ),
              ),
              trailing: isEmptyStock
                  ? const Text(
                      "Kosong",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: Color(0xFFF9A825),
                        )
                      : const Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.white24,
                        ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedPartInfo() {
    final selectedPart = _selectedPart();

    if (selectedPart == null) {
      return const SizedBox.shrink();
    }

    final name = _getPartName(selectedPart);
    final sku = _getPartSku(selectedPart);
    final stock = _getStock(selectedPart);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9A825).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF9A825).withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        "Dipilih: $sku — $name • Stok tersedia: $stock",
        style: const TextStyle(
          color: Color(0xFFF9A825),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Request Sparepart",
                style: TextStyle(
                  color: Color(0xFFF9A825),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.unitName,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Search aktif otomatis saat diketik. Pilih part dari list, lalu masukkan qty yang dibutuhkan.",
                style: TextStyle(
                  color: Colors.white30,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              _buildSearchField(),
              const SizedBox(height: 12),
              _buildPartPicker(),
              _buildSelectedPartInfo(),
              const SizedBox(height: 12),
              TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Qty",
                  labelStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Catatan",
                  hintText: "Contoh: Butuh untuk penggantian filter...",
                  labelStyle: TextStyle(color: Colors.white38),
                  hintStyle: TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9A825),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                        )
                      : const Text(
                          "KIRIM REQUEST",
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
      ),
    );
  }
}
