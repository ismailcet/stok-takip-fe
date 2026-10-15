class Part {
  final int id;
  final String name;
  final String? barcode;
  final String? productCode;
  final String? brand;
  final String? category;
  final int cabinetId;
  final String cabinetName;
  final int stockQuantity;

  Part({
    required this.id,
    required this.name,
    this.barcode,
    this.productCode,
    this.brand,
    this.category,
    required this.cabinetId,
    required this.cabinetName,
    required this.stockQuantity,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: json['id'] as int,
      name: json['name'] as String,
      barcode: json['barcode'] as String?,
      productCode: json['productCode'] as String?,
      brand: json['brand'] as String?,
      category: json['category'] as String?,
      cabinetId: json['cabinetId'] as int,
      cabinetName: json['cabinetName'] as String,
      stockQuantity: json['stockQuantity'] as int,
    );
  }
}
