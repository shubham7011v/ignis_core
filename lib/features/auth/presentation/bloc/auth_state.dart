import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failure.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  Authenticated copyWith({User? user}) {
    return Authenticated(user ?? this.user);
  }

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final Failure failure;
  const AuthFailure(this.failure);

  @override
  List<Object?> get props => [failure];

  @override
  String toString() => failure.toString();
}
