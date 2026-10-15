import '../models/user_role.dart';

class CurrentUser {
  final int id;
  final String fullName;
  final UserRole role;

  const CurrentUser({
    required this.id,
    required this.fullName,
    required this.role,
  });
}

class Session {
  Session._();

  static CurrentUser? current;

  static void clear() {
    current = null;
  }
}
