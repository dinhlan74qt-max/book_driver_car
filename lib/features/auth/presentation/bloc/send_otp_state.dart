import 'package:equatable/equatable.dart';

abstract class SendOtpState extends Equatable {
  const SendOtpState();
  @override
  List<Object?> get props => [];
}

class SendOtpInitial extends SendOtpState {}

class SendOtpLoading extends SendOtpState {}

class SendOtpSuccess extends SendOtpState {
  final String message;
  const SendOtpSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SendOtpFailure extends SendOtpState {
  final String error;
  const SendOtpFailure(this.error);

  @override
  List<Object?> get props => [error];
}