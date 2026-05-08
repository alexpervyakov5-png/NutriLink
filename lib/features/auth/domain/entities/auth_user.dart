import 'package:equatable/equatable.dart';

enum UserRole { client, trainer }

class AuthUser extends Equatable {
  final String id;
  final String email;
  final String? username;
  final UserRole role;
  final DateTime? createdAt;

  const AuthUser({
    required this.id,
    required this.email,
    this.username,
    this.role = UserRole.client,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, username, role, createdAt];
}