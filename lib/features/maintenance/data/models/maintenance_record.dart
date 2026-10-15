class MaintenanceRecord {
  final int id;
  final int companyId;
  final String companyName;
  final String? companyAddress;
  final String? companyTaxOffice;
  final String? companyTaxNumber;
  final String? companyPhone;
  final DateTime visitDate;
  final int recordedByUserId;
  final String recordedByUserName;
  final DateTime? createdAt;

  const MaintenanceRecord({
    required this.id,
    required this.companyId,
    required this.companyName,
    this.companyAddress,
    this.companyTaxOffice,
    this.companyTaxNumber,
    this.companyPhone,
    required this.visitDate,
    required this.recordedByUserId,
    required this.recordedByUserName,
    this.createdAt,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'] as String?;
    return MaintenanceRecord(
      id: json['id'] as int,
      companyId: json['companyId'] as int,
      companyName: json['companyName'] as String,
      companyAddress: json['companyAddress'] as String?,
      companyTaxOffice: json['companyTaxOffice'] as String?,
      companyTaxNumber: json['companyTaxNumber'] as String?,
      companyPhone: json['companyPhone'] as String?,
      visitDate: DateTime.parse(json['visitDate'] as String),
      recordedByUserId: json['recordedByUserId'] as int,
      recordedByUserName: json['recordedByUserName'] as String,
      createdAt: created == null ? null : DateTime.parse(created),
    );
  }
}
