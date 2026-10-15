import '../../../../core/network/api_client.dart';
import '../models/named_item.dart';

/// `/companies` veya `/cabinets` gibi {id, name} kaynaklarını yönetir.
class NamedItemRepository {
  NamedItemRepository({required this.path, ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final String path;
  final ApiClient _apiClient;

  Future<List<NamedItem>> list() async {
    final data = await _apiClient.get(path);
    return (data as List)
        .map((e) => NamedItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NamedItem> create(String name) async {
    final data = await _apiClient.post(path, body: {'name': name});
    return NamedItem.fromJson(data as Map<String, dynamic>);
  }

  Future<NamedItem> rename(int id, String name) async {
    final data = await _apiClient.patch('$path/$id', body: {'name': name});
    return NamedItem.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _apiClient.delete('$path/$id');
  }
}
