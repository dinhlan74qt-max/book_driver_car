import 'package:equatable/equatable.dart';

abstract class MyVehiclesEvent extends Equatable {
  const MyVehiclesEvent();

  @override
  List<Object?> get props => [];
}

class MyVehiclesRequested extends MyVehiclesEvent {
  const MyVehiclesRequested();
}
