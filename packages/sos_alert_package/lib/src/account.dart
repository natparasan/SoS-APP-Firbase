import 'user_role.dart';

class Account {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  const Account({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });
}
