import 'package:equatable/equatable.dart';
import '../../domain/entities/add_vehicle_request_entity.dart';

abstract class AddVehicleEvent extends Equatable {
  const AddVehicleEvent();
  @override
  List<Object?> get props => [];
}

class AddVehicleSubmitted extends AddVehicleEvent {
  final AddVehicleRequestEntity request;
  const AddVehicleSubmitted(this.request);

  @override
  List<Object?> get props => [request];
}