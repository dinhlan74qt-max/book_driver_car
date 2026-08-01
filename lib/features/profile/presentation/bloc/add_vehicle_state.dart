import 'package:equatable/equatable.dart';
import '../../domain/entities/vehicle_entity.dart';

abstract class AddVehicleState extends Equatable {
  const AddVehicleState();
  @override
  List<Object?> get props => [];
}

class AddVehicleInitial extends AddVehicleState {}

class AddVehicleLoading extends AddVehicleState {}

class AddVehicleSuccess extends AddVehicleState {
  final VehicleEntity vehicle;
  const AddVehicleSuccess(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

class AddVehicleFailure extends AddVehicleState {
  final String error;
  const AddVehicleFailure(this.error);

  @override
  List<Object?> get props => [error];
}