import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/domain/repositories/home_repository.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;

  HomeCubit(this.repository) : super(HomeInitial());

  Future<void> fetchCars() async {
    emit(HomeLoading());
    try {
      final cars = await repository.getCars();

      final nearbyCars = List<CarEntity>.from(cars)
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      final suggestedCars = List<CarEntity>.from(cars)
        ..sort((a, b) => b.rating.compareTo(a.rating));

      emit(HomeLoaded(
        cars: cars,
        nearbyCars: nearbyCars,
        suggestedCars: suggestedCars,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> searchCars({
    String? locationMode,
    String? locationLabel,
    double? latitude,
    double? longitude,
    String? vehicleType,
    String? brand,
    String? model,
  }) async {
    emit(HomeLoading());
    try {
      final cars = await repository.searchCars(
        locationMode: locationMode,
        locationLabel: locationLabel,
        latitude: latitude,
        longitude: longitude,
        vehicleType: vehicleType,
        brand: brand,
        model: model,
      );

      final nearbyCars = List<CarEntity>.from(cars)
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      final suggestedCars = List<CarEntity>.from(cars)
        ..sort((a, b) => b.rating.compareTo(a.rating));

      emit(HomeLoaded(
        cars: cars,
        nearbyCars: nearbyCars,
        suggestedCars: suggestedCars,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> searchCarsByCity(String cityName) async {
    emit(HomeLoading());
    try {
      final cars = await repository.searchCarsByCity(cityName);

      final nearbyCars = List<CarEntity>.from(cars)
        ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      final suggestedCars = List<CarEntity>.from(cars)
        ..sort((a, b) => b.rating.compareTo(a.rating));

      emit(HomeLoaded(
        cars: cars,
        nearbyCars: nearbyCars,
        suggestedCars: suggestedCars,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
