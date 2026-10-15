import '../../../../core/models/user_role.dart';
import '../../../../core/network/api_client.dart';
import '../models/managed_user.dart';

class UserAdminRepository {
  UserAdminRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ManagedUser>> list() async {
    final data = await _apiClient.get('/users');
    return (data as List)
        .map((e) => ManagedUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create({
    required String fullName,
    required UserRole role,
    required String pin,
  }) async {
    await _apiClient.post(
      '/users',
      body: {'fullName': fullName, 'role': roleToApi(role), 'pin': pin},
    );
  }

  Future<void> resetPin(int userId, String newPin) async {
    await _apiClient.patch('/users/$userId/pin', body: {'newPin': newPin});
  }
}
