import '../../../../core/network/api_client.dart';
import '../models/part.dart';

class PartRepository {
  PartRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Part>> list({String? search, bool lowStockOnly = false}) async {
    final data = await _apiClient.get(
      '/parts',
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        'lowStockOnly': lowStockOnly.toString(),
      },
    );
    return (data as List)
        .map((e) => Part.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Barkod veya ürün koduna göre parça bulur. Bulunamazsa (404) null döner.
  Future<Part?> lookup({String? barcode, String? productCode}) async {
    try {
      final data = await _apiClient.get(
        '/parts/lookup',
        query: {
          if (barcode != null && barcode.isNotEmpty) 'barcode': barcode,
          if (productCode != null && productCode.isNotEmpty)
            'productCode': productCode,
        },
      );
      return Part.fromJson(data as Map<String, dynamic>);
    } on Exception catch (e) {
      if (e.toString().contains('(404)')) return null;
      rethrow;
    }
  }

  /// Elle yazılan kod: önce barkod, bulunamazsa ürün kodu olarak arar.
  Future<Part?> lookupByAnyCode(String code) async {
    final byBarcode = await lookup(barcode: code);
    if (byBarcode != null) return byBarcode;
    return lookup(productCode: code);
  }

  Future<Part> create({
    required String name,
    String? barcode,
    String? productCode,
    String? brand,
    String? category,
    required int cabinetId,
    required int stockQuantity,
  }) async {
    final data = await _apiClient.post(
      '/parts',
      body: {
        'name': name,
        'barcode': barcode,
        'productCode': productCode,
        'brand': brand,
        'category': category,
        'cabinetId': cabinetId,
        'stockQuantity': stockQuantity,
      },
    );
    return Part.fromJson(data as Map<String, dynamic>);
  }

  Future<Part> update(
    int id, {
    required int cabinetId,
    required int stockQuantity,
    String? brand,
  }) async {
    final data = await _apiClient.patch(
      '/parts/$id',
      body: {
        'cabinetId': cabinetId,
        'stockQuantity': stockQuantity,
        'brand': brand,
      },
    );
    return Part.fromJson(data as Map<String, dynamic>);
  }
}
