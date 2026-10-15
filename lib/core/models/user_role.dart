enum UserRole { admin, usta, cirak }

extension UserRoleX on UserRole {
  static UserRole fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'MASTER':
        return UserRole.usta;
      case 'APPRENTICE':
        return UserRole.cirak;
      default:
        throw ArgumentError('Bilinmeyen rol: $value');
    }
  }

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Yönetici';
      case UserRole.usta:
        return 'Usta';
      case UserRole.cirak:
        return 'Çırak';
    }
  }

  /// Parça ekleyip güncelleyebilir (Usta ve Yönetici).
  bool get canEditParts => this == UserRole.usta || this == UserRole.admin;

  /// Firma, dolap ve kullanıcı yönetimi (sadece Yönetici).
  bool get canManage => this == UserRole.admin;
}
