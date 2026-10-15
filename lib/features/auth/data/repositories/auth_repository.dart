import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/session/session.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_account.dart';

class AuthRepository {
  AuthRepository({SecureStorageService? storage})
    : _storage = storage ?? SecureStorageService.instance;

  final SecureStorageService _storage;

  Future<List<UserAccount>> fetchAccounts() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/users'));
    if (res.statusCode != 200) {
      throw Exception('Hesap listesi alınamadı (${res.statusCode})');
    }
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((e) => UserAccount.fromJson(e)).toList();
  }

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

    // Uygulama yeniden açılınca oturumu geri yükleyebilmek için kullanıcıyı da sakla.
    final role = UserRoleX.fromApi(data['role'] as String);
    await _storage.saveUser(
      jsonEncode({
        'id': data['id'],
        'fullName': data['fullName'],
        'role': role.name,
      }),
    );
  }

  /// Kayıtlı token ve kullanıcı geçerliyse oturumu açar. Geçerli oturum yoksa false döner.
  Future<bool> restoreSession() async {
    final token = await _storage.readToken();
    final userJson = await _storage.readUser();

    if (token == null || userJson == null || _isExpired(token)) {
      await _storage.clearAll();
      return false;
    }

    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      Session.current = CurrentUser(
        id: map['id'] as int,
        fullName: map['fullName'] as String,
        role: UserRole.values.byName(map['role'] as String),
      );
      return true;
    } catch (_) {
      await _storage.clearAll();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    Session.clear();
  }

  bool _isExpired(String token) {
    try {
      final parts = token.split('.');
      final payload = utf8.decode(base64Url.decode(base64.normalize(parts[1])));
      final exp = (jsonDecode(payload) as Map<String, dynamic>)['exp'] as int;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return true;
    }
  }
}
