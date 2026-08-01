import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_result_entity.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final AuthResultEntity result;
  const LoginSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class LoginFailure extends LoginState {
  final String error;
  const LoginFailure(this.error);

  @override
  List<Object?> get props => [error];
}