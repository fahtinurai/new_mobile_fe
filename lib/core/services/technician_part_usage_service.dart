import 'package:djatimobile_project/core/services/api_service.dart';

class TechnicianPartUsageService {
  /// Ambil daftar sparepart untuk dipilih teknisi.
  ///
  /// Backend:
  /// GET /api/technician/parts?search=...
  static Future<List<dynamic>> getParts({
    String search = "",
  }) async {
    final endpoint = search.trim().isEmpty
        ? "/technician/parts"
        : "/technician/parts?search=${Uri.encodeQueryComponent(search.trim())}";

    final result = await ApiService.get(endpoint);

    final statusCode = result["statusCode"];
    final data = result["data"];

    if (statusCode == 200) {
      return _extractList(data);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "Gagal mengambil daftar sparepart.",
      ),
    );
  }

  /// Teknisi request sparepart.
  ///
  /// Backend:
  /// POST /api/technician/part-usages
  ///
  /// Body:
  /// {
  ///   "part_id": 1,
  ///   "damage_report_id": 5,
  ///   "qty": 2,
  ///   "note": "Catatan"
  /// }
  static Future<Map<String, dynamic>> requestPartUsage({
    required int partId,
    required int damageReportId,
    required int qty,
    String? note,
  }) async {
    if (partId <= 0) {
      throw Exception("Sparepart wajib dipilih.");
    }

    if (damageReportId <= 0) {
      throw Exception("Damage report ID tidak valid.");
    }

    if (qty < 1) {
      throw Exception("Qty minimal 1.");
    }

    final body = {
      "part_id": partId,
      "damage_report_id": damageReportId,
      "qty": qty,
      if (note != null && note.trim().isNotEmpty) "note": note.trim(),
    };

    final result = await ApiService.post(
      "/technician/part-usages",
      body,
    );

    final statusCode = result["statusCode"];
    final data = result["data"];

    if (statusCode == 200 || statusCode == 201) {
      return _extractMap(data) ??
          {
            "message": "Request sparepart berhasil dikirim.",
            "data": data,
          };
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "Gagal mengirim request sparepart.",
      ),
    );
  }

  /// Riwayat request sparepart teknisi login.
  ///
  /// Backend:
  /// GET /api/technician/my-part-usages
  static Future<List<dynamic>> getMyPartUsages() async {
    final result = await ApiService.get(
      "/technician/my-part-usages",
    );

    final statusCode = result["statusCode"];
    final data = result["data"];

    if (statusCode == 200) {
      return _extractList(data);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "Gagal mengambil riwayat request sparepart.",
      ),
    );
  }

  static int extractPartUsageId(Map<String, dynamic> value) {
    final data = _extractMap(value) ?? value;

    final possibleId = data["id"] ??
        data["part_usage_id"] ??
        data["usage"]?["id"] ??
        data["data"]?["id"];

    return int.tryParse(possibleId?.toString() ?? "") ?? 0;
  }

  static String getStatusLabel(dynamic statusValue) {
    final status = statusValue?.toString().toLowerCase() ?? "requested";

    switch (status) {
      case "requested":
      case "pending":
        return "Pending";

      case "approved":
        return "Approved";

      case "rejected":
        return "Rejected";

      default:
        return statusValue?.toString() ?? "Pending";
    }
  }

  static bool isPending(dynamic statusValue) {
    final status = statusValue?.toString().toLowerCase() ?? "";

    return status == "requested" || status == "pending";
  }

  static bool isApproved(dynamic statusValue) {
    final status = statusValue?.toString().toLowerCase() ?? "";

    return status == "approved";
  }

  static bool isRejected(dynamic statusValue) {
    final status = statusValue?.toString().toLowerCase() ?? "";

    return status == "rejected";
  }

  static List<dynamic> _extractList(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final nestedData = data["data"];

      if (nestedData is List) {
        return nestedData;
      }

      if (nestedData is Map<String, dynamic>) {
        final paginatedData = nestedData["data"];

        if (paginatedData is List) {
          return paginatedData;
        }

        final nestedParts = nestedData["parts"];
        if (nestedParts is List) {
          return nestedParts;
        }

        final nestedSpareparts = nestedData["spareparts"];
        if (nestedSpareparts is List) {
          return nestedSpareparts;
        }

        final nestedSpareParts = nestedData["spare_parts"];
        if (nestedSpareParts is List) {
          return nestedSpareParts;
        }
      }

      final rows = data["rows"];
      if (rows is List) {
        return rows;
      }

      final parts = data["parts"];
      if (parts is List) {
        return parts;
      }

      final spareparts = data["spareparts"];
      if (spareparts is List) {
        return spareparts;
      }

      final spareParts = data["spare_parts"];
      if (spareParts is List) {
        return spareParts;
      }

      final usages = data["usages"];
      if (usages is List) {
        return usages;
      }

      final usage = data["usage"];
      if (usage is List) {
        return usage;
      }
    }

    if (data is Map) {
      return _extractList(
        Map<String, dynamic>.from(data),
      );
    }

    return [];
  }

  static Map<String, dynamic>? _extractMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nestedData = data["data"];

      if (nestedData is Map<String, dynamic>) {
        return nestedData;
      }

      if (nestedData is Map) {
        return Map<String, dynamic>.from(nestedData);
      }

      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  static String _extractErrorMessage(
    dynamic data,
    String fallback,
  ) {
    if (data is Map<String, dynamic>) {
      final message = data["message"]?.toString();

      if (message != null && message.isNotEmpty) {
        return message;
      }

      final errors = data["errors"];

      if (errors is Map && errors.isNotEmpty) {
        final firstValue = errors.values.first;

        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }

        return firstValue.toString();
      }
    }

    if (data is Map) {
      final mapped = Map<String, dynamic>.from(data);
      final message = mapped["message"]?.toString();

      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return fallback;
  }
}