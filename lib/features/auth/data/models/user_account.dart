import '../../../../core/models/user_role.dart';

export '../../../../core/models/user_role.dart';

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
