import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';
import '../constants/api_constants.dart';

class ApiService {
  static const String baseUrl = ApiConstants.baseUrl;

  // HEADER (pakai token kalau ada)
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  // SAFE JSON DECODE
  static dynamic _safeJsonDecode(String body) {
    if (body.trim().isEmpty) {
      return {
        "message": "Empty response",
      };
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return {
        "message": body,
      };
    }
  }

  // FORMAT RESPONSE
  static Map<String, dynamic> _formatResponse(
    http.Response response,
  ) {
    final data = _safeJsonDecode(response.body);

    return {
      "statusCode": response.statusCode,
      "data": data,
    };
  }

  // LOGIN (tanpa token)
  static Future<Map<String, dynamic>> login(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      return _formatResponse(response);
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {
          "message": "Error: $e",
        },
      };
    }
  }

  // GET
  static Future<Map<String, dynamic>> get(
    String endpoint,
  ) async {
    try {
      final headers = await _headers();

      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: headers,
      );

      return _formatResponse(response);
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {
          "message": "Error: $e",
        },
      };
    }
  }

  // POST
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _headers();

      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: headers,
        body: jsonEncode(body),
      );

      return _formatResponse(response);
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {
          "message": "Error: $e",
        },
      };
    }
  }

  // PUT
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _headers();

      final response = await http.put(
        Uri.parse("$baseUrl$endpoint"),
        headers: headers,
        body: jsonEncode(body),
      );

      return _formatResponse(response);
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {
          "message": "Error: $e",
        },
      };
    }
  }
}