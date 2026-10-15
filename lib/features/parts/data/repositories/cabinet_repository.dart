import '../../../../core/network/api_client.dart';
import '../models/cabinet.dart';

class CabinetRepository {
  CabinetRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Cabinet>> list() async {
    final data = await _apiClient.get('/cabinets');
    return (data as List)
        .map((e) => Cabinet.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
