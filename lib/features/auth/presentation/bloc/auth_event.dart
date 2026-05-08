import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_user.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  AuthSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String username;
  final UserRole role;

  AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.username,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, username, role];
}

class AuthSignOutRequested extends AuthEvent {}