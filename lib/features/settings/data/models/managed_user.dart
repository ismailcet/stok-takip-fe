import '../../../../core/models/user_role.dart';

class ManagedUser {
  final int id;
  final String fullName;
  final UserRole role;

  const ManagedUser({
    required this.id,
    required this.fullName,
    required this.role,
  });

  factory ManagedUser.fromJson(Map<String, dynamic> json) {
    return ManagedUser(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      role: UserRoleX.fromApi(json['role'] as String),
    );
  }
}

/// UserRole → backend'in beklediği değer.
String roleToApi(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'ADMIN';
    case UserRole.usta:
      return 'MASTER';
    case UserRole.cirak:
      return 'APPRENTICE';
  }
}
