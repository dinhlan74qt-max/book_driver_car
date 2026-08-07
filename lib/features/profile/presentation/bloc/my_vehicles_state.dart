import 'package:equatable/equatable.dart';

import '../../domain/entities/vehicle_entity.dart';

abstract class MyVehiclesState extends Equatable {
  const MyVehiclesState();

  @override
  List<Object?> get props => [];
}

class MyVehiclesInitial extends MyVehiclesState {}

class MyVehiclesLoading extends MyVehiclesState {}

class MyVehiclesLoaded extends MyVehiclesState {
  final List<VehicleEntity> vehicles;

  const MyVehiclesLoaded(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

class MyVehiclesFailure extends MyVehiclesState {
  final String error;

  const MyVehiclesFailure(this.error);

  @override
  List<Object?> get props => [error];
}
