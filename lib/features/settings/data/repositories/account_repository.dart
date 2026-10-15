import '../../../../core/network/api_client.dart';

class AccountRepository {
  AccountRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<void> changeOwnPin({
    required String currentPin,
    required String newPin,
  }) async {
    // Yanlış mevcut PIN 401 döner; bu bir oturum hatası değil, çıkış yaptırma.
    await _apiClient.patch(
      '/users/me/pin',
      body: {'currentPin': currentPin, 'newPin': newPin},
      signOutOn401: false,
    );
  }
}
