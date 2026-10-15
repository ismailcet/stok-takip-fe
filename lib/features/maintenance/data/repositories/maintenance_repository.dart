import '../../../../core/network/api_client.dart';
import '../models/company.dart';
import '../models/maintenance_record.dart';

class MaintenanceRepository {
  MaintenanceRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<MaintenanceRecord>> listRecords({int? companyId}) async {
    final data = await _apiClient.get(
      '/maintenance-records',
      query: {if (companyId != null) 'companyId': companyId.toString()},
    );
    return (data as List)
        .map((e) => MaintenanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// [activeOnly] true ise gizli firmalar gelmez (yeni bakım kaydı ekranı için).
  /// Bakım listesindeki filtre tüm firmaları ister, çünkü gizli firmaların da kayıtları vardır.
  Future<List<Company>> listCompanies({bool activeOnly = false}) async {
    final data = await _apiClient.get(
      '/companies',
      query: {if (activeOnly) 'activeOnly': 'true'},
    );
    return (data as List)
        .map((e) => Company.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MaintenanceRecord> create({
    required int companyId,
    required DateTime visitDate,
    required String photoPath,
  }) async {
    final month = visitDate.month.toString().padLeft(2, '0');
    final day = visitDate.day.toString().padLeft(2, '0');
    final data = await _apiClient.postMultipart(
      '/maintenance-records',
      fields: {
        'companyId': companyId.toString(),
        'visitDate': '${visitDate.year}-$month-$day',
      },
      fileField: 'photo',
      filePath: photoPath,
    );
    return MaintenanceRecord.fromJson(data as Map<String, dynamic>);
  }
}
