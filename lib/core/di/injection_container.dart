// lib/injection_container.dart
import 'package:book_drive_car/features/profile/data/datasources/vehicle_remote_data_source.dart';
import 'package:book_drive_car/features/profile/data/repositories/vehicle_repository_impl.dart';
import 'package:book_drive_car/features/profile/domain/repositories/vehicle_repository.dart';
import 'package:book_drive_car/features/profile/domain/usecases/add_vehicle.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/add_vehicle_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injectable_modules.dart';

import 'injection_container.config.dart';

final sl = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await sl.init();
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: const {'Accept': 'application/json'},
        ),
      ),
    );
  }

  if (!sl.isRegistered<VehicleRemoteDataSource>()) {
    sl.registerLazySingleton<VehicleRemoteDataSource>(
      () => VehicleRemoteDataSourceImpl(sl<Dio>(), sl()),
    );
  }

  if (!sl.isRegistered<VehicleRepository>()) {
    sl.registerLazySingleton<VehicleRepository>(
      () => VehicleRepositoryImpl(sl<VehicleRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<AddVehicle>()) {
    sl.registerFactory<AddVehicle>(() => AddVehicle(sl<VehicleRepository>()));
  }

  if (!sl.isRegistered<AddVehicleBloc>()) {
    sl.registerFactory<AddVehicleBloc>(() => AddVehicleBloc(sl<AddVehicle>()));
  }
}
