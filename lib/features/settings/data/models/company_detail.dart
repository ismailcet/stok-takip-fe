class CompanyDetail {
  final int id;
  final String name;
  final String? address;
  final String? taxOffice;
  final String? taxNumber;
  final String? phone;
  final bool hidden;

  const CompanyDetail({
    required this.id,
    required this.name,
    this.address,
    this.taxOffice,
    this.taxNumber,
    this.phone,
    this.hidden = false,
  });

  factory CompanyDetail.fromJson(Map<String, dynamic> json) {
    return CompanyDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      taxOffice: json['taxOffice'] as String?,
      taxNumber: json['taxNumber'] as String?,
      phone: json['phone'] as String?,
      hidden: json['hidden'] as bool? ?? false,
    );
  }

  /// Eski kayıtlarda zorunlu bilgiler henüz girilmemiş olabilir.
  bool get hasMissingInfo =>
      _blank(address) || _blank(taxOffice) || _blank(taxNumber);

  static bool _blank(String? s) => s == null || s.trim().isEmpty;
}

class CompanyInput {
  final String name;
  final String address;
  final String taxOffice;
  final String taxNumber;
  final String phone; // opsiyonel, boş olabilir

  const CompanyInput({
    required this.name,
    required this.address,
    required this.taxOffice,
    required this.taxNumber,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'taxOffice': taxOffice,
    'taxNumber': taxNumber,
    'phone': phone.isEmpty ? null : phone,
  };
}
