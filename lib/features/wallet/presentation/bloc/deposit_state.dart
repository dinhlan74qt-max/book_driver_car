import 'package:equatable/equatable.dart';
import '../../domain/entities/deposit_result_entity.dart';

abstract class DepositState extends Equatable {
  const DepositState();
  @override
  List<Object?> get props => [];
}

class DepositInitial extends DepositState {}

class DepositLoading extends DepositState {}

class DepositSuccess extends DepositState {
  final DepositResultEntity result;
  const DepositSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class DepositFailure extends DepositState {
  final String error;
  const DepositFailure(this.error);

  @override
  List<Object?> get props => [error];
}