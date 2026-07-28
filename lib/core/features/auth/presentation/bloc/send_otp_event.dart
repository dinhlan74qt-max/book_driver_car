import 'package:equatable/equatable.dart';
import '../../domain/entities/register_request_entity.dart';

abstract class SendOtpEvent extends Equatable {
  const SendOtpEvent();
  @override
  List<Object?> get props => [];
}

class SendOtpSubmitted extends SendOtpEvent {
  final RegisterRequestEntity request;
  const SendOtpSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}