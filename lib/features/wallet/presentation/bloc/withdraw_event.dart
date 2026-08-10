import 'package:equatable/equatable.dart';
import '../../domain/entities/withdraw_request_entity.dart';

abstract class WithdrawEvent extends Equatable {
  const WithdrawEvent();
  @override
  List<Object?> get props => [];
}

class WithdrawSubmitted extends WithdrawEvent {
  final WithdrawRequestEntity request;
  const WithdrawSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}