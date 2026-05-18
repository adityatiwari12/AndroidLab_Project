import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// 10.0.2.2 is the Android emulator alias for localhost
const _baseUrl = 'http://10.0.2.2:3001/api';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();

  // ── Students ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getStudents({String? status}) async {
    final uri = Uri.parse('$_baseUrl/students${status != null ? '?status=$status' : ''}');
    final res = await _client.get(uri).timeout(const Duration(seconds: 5));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(res.body));
    throw Exception('Failed to load students: ${res.statusCode}');
  }

  // ── Activities ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getActivities(String userId) async {
    final res = await _client.get(Uri.parse('$_baseUrl/activities/student/$userId')).timeout(const Duration(seconds: 5));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(res.body));
    throw Exception('Failed to load activities');
  }

  Future<Map<String, dynamic>> postActivity(Map<String, dynamic> data) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/activities'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode == 201) return Map<String, dynamic>.from(json.decode(res.body));
    throw Exception('Failed to submit activity');
  }

  // ── Coding ────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getCoding(String userId) async {
    final res = await _client.get(Uri.parse('$_baseUrl/coding/student/$userId')).timeout(const Duration(seconds: 5));
    if (res.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(res.body));
    throw Exception('Failed to load coding activities');
  }

  Future<Map<String, dynamic>> postCoding(Map<String, dynamic> data) async {
    final res = await _client.post(
      Uri.parse('$_baseUrl/coding'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode == 201) return Map<String, dynamic>.from(json.decode(res.body));
    throw Exception('Failed to submit coding entry');
  }

  // ── File upload ───────────────────────────────────────────────────────────

  Future<String?> uploadFile(File file, String type) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload/$type'));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        return body['url'] as String?;
      }
    } catch (_) {
      // Backend offline — work offline only
    }
    return null;
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getOverviewStats() async {
    try {
      final res = await _client.get(Uri.parse('$_baseUrl/stats/overview')).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) return Map<String, dynamic>.from(json.decode(res.body));
    } catch (_) {}
    return null;
  }
}
