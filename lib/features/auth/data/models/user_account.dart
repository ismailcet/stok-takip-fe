enum UserRole { usta, cirak }

extension UserRoleX on UserRole {
  static UserRole fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'MASTER':
        return UserRole.usta;
      case 'APPRENTICE':
        return UserRole.cirak;
      default:
        throw ArgumentError('Bilinmeyen rol: $value');
    }
  }

  String get label => this == UserRole.usta ? 'Usta' : 'Çırak';
}

class UserAccount {
  final int id;
  final String fullName;
  final UserRole role;

  UserAccount({required this.id, required this.fullName, required this.role});

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      role: UserRoleX.fromApi(json['role'] as String),
    );
  }
}
