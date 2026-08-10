import 'package:equatable/equatable.dart';

abstract class WithdrawState extends Equatable {
  const WithdrawState();
  @override
  List<Object?> get props => [];
}

class WithdrawInitial extends WithdrawState {}

class WithdrawLoading extends WithdrawState {}

class WithdrawSuccess extends WithdrawState {
  final String message;
  const WithdrawSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class WithdrawFailure extends WithdrawState {
  final String error;
  const WithdrawFailure(this.error);

  @override
  List<Object?> get props => [error];
}