import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../navigation/app_navigator.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  ApiClient({SecureStorageService? storage})
    : _storage = storage ?? SecureStorageService.instance;

  final SecureStorageService _storage;

  Future<Map<String, String>> _headers({bool json = false}) async {
    final token = await _storage.readToken();
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}$path',
    ).replace(queryParameters: query);
    final res = await http.get(uri, headers: await _headers());
    return _handle(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final res = await http.post(
      uri,
      headers: await _headers(json: true),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  /// [signOutOn401] false ise 401 oturum hatası sayılmaz (örn. yanlış mevcut PIN).
  Future<dynamic> patch(
    String path, {
    Object? body,
    bool signOutOn401 = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final res = await http.patch(
      uri,
      headers: await _headers(json: true),
      body: jsonEncode(body),
    );
    return _handle(res, signOutOn401: signOutOn401);
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final res = await http.delete(uri, headers: await _headers());
    return _handle(res);
  }

  /// Dosya yüklemeli (multipart/form-data) POST.
  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    required String filePath,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final request =
        http.MultipartRequest('POST', uri)
          ..headers.addAll(await _headers())
          ..fields.addAll(fields)
          ..files.add(await http.MultipartFile.fromPath(fileField, filePath));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  dynamic _handle(http.Response res, {bool signOutOn401 = true}) {
    if (res.statusCode == 401 && signOutOn401) {
      handleSessionExpired();
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('İstek başarısız (${res.statusCode})');
    }
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }
}
