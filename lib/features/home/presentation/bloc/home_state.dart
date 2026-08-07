import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CarEntity> cars;
  final List<CarEntity> nearbyCars;
  final List<CarEntity> suggestedCars;

  const HomeLoaded({
    required this.cars,
    required this.nearbyCars,
    required this.suggestedCars,
  });

  @override
  List<Object> get props => [cars, nearbyCars, suggestedCars];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
