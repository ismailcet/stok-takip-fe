import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_account.dart';

class AuthRepository {
  AuthRepository({SecureStorageService? storage})
    : _storage = storage ?? SecureStorageService.instance;

  final SecureStorageService _storage;

  // TODO: yolu kendi AuthController'ınızdaki endpoint ile doğrulayın.
  Future<List<UserAccount>> fetchAccounts() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/auth/users'));
    if (res.statusCode != 200) {
      throw Exception('Hesap listesi alınamadı (${res.statusCode})');
    }
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((e) => UserAccount.fromJson(e)).toList();
  }

  // TODO: request/response alan adlarını backend DTO'nuzla doğrulayın.
  Future<void> login({required int userId, required String pin}) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'pin': pin}),
    );

    if (res.statusCode != 200) {
      throw Exception('Giriş başarısız (${res.statusCode})');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    await _storage.saveToken(data['token'] as String);
  }
}
