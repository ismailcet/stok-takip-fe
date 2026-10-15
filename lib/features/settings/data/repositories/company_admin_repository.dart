import '../../../../core/network/api_client.dart';
import '../models/company_detail.dart';

class CompanyAdminRepository {
  CompanyAdminRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<CompanyDetail>> list() async {
    final data = await _apiClient.get('/companies');
    return (data as List)
        .map((e) => CompanyDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> create(CompanyInput input) async {
    await _apiClient.post('/companies', body: input.toJson());
  }

  Future<void> update(int id, CompanyInput input) async {
    await _apiClient.patch('/companies/$id', body: input.toJson());
  }

  Future<void> setHidden(int id, bool hidden) async {
    await _apiClient.patch(
      '/companies/$id/visibility',
      body: {'hidden': hidden},
    );
  }

  Future<void> delete(int id) async {
    await _apiClient.delete('/companies/$id');
  }
}
