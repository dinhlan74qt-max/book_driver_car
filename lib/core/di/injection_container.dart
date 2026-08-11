// lib/injection_container.dart
import 'package:book_drive_car/features/profile/data/datasources/owner_booking_remote_data_source.dart';
import 'package:book_drive_car/features/profile/data/repositories/owner_booking_repository_impl.dart';
import 'package:book_drive_car/features/profile/domain/repositories/owner_booking_repository.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_cubit.dart';
import 'package:book_drive_car/features/home/data/datasources/home_remote_data_source.dart';
import 'package:book_drive_car/features/home/data/datasources/booking_remote_data_source.dart';
import 'package:book_drive_car/features/home/data/repositories/home_repository_impl.dart';
import 'package:book_drive_car/features/home/domain/repositories/home_repository.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_cubit.dart';
import 'package:book_drive_car/features/rental/data/datasources/rental_remote_data_source.dart';
import 'package:book_drive_car/features/rental/data/repositories/rental_repository_impl.dart';
import 'package:book_drive_car/features/rental/domain/repositories/rental_repository.dart';
import 'package:book_drive_car/features/rental/domain/usecases/get_renter_bookings.dart';
import 'package:book_drive_car/features/profile/data/datasources/vehicle_remote_data_source.dart';
import 'package:book_drive_car/features/profile/data/repositories/vehicle_repository_impl.dart';
import 'package:book_drive_car/features/profile/domain/repositories/vehicle_repository.dart';
import 'package:book_drive_car/features/profile/domain/usecases/add_vehicle.dart';
import 'package:book_drive_car/features/profile/domain/usecases/get_my_vehicles.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/add_vehicle_bloc.dart';
import 'package:book_drive_car/features/profile/presentation/bloc/my_vehicles_bloc.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:book_drive_car/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:book_drive_car/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:book_drive_car/features/wallet/domain/usecases/deposit.dart';
import 'package:book_drive_car/features/wallet/domain/usecases/get_my_wallet.dart';
import 'package:book_drive_car/features/wallet/domain/usecases/withdraw.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/deposit_bloc.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:book_drive_car/features/wallet/presentation/bloc/withdraw_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection_container.config.dart';

final sl = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  sl.init();
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 60),
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

  if (!sl.isRegistered<BookingRemoteDataSource>()) {
    sl.registerLazySingleton<BookingRemoteDataSource>(
      () => BookingRemoteDataSourceImpl(sl<Dio>(), sl<UserLocalStorage>()),
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

  if (!sl.isRegistered<GetMyVehicles>()) {
    sl.registerFactory<GetMyVehicles>(
      () => GetMyVehicles(sl<VehicleRepository>()),
    );
  }

  if (!sl.isRegistered<MyVehiclesBloc>()) {
    sl.registerFactory<MyVehiclesBloc>(
      () => MyVehiclesBloc(sl<GetMyVehicles>()),
    );
  }

  if (!sl.isRegistered<WalletRemoteDataSource>()) {
    sl.registerLazySingleton<WalletRemoteDataSource>(
      () => WalletRemoteDataSourceImpl(sl<Dio>(), sl<UserLocalStorage>()),
    );
  }

  if (!sl.isRegistered<WalletRepository>()) {
    sl.registerLazySingleton<WalletRepository>(
      () => WalletRepositoryImpl(sl<WalletRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<GetMyWallet>()) {
    sl.registerFactory<GetMyWallet>(() => GetMyWallet(sl<WalletRepository>()));
  }

  if (!sl.isRegistered<Deposit>()) {
    sl.registerFactory<Deposit>(() => Deposit(sl<WalletRepository>()));
  }

  if (!sl.isRegistered<Withdraw>()) {
    sl.registerFactory<Withdraw>(() => Withdraw(sl<WalletRepository>()));
  }

  if (!sl.isRegistered<WalletBloc>()) {
    sl.registerFactory<WalletBloc>(() => WalletBloc(sl<WalletRepository>()));
  }

  if (!sl.isRegistered<DepositBloc>()) {
    sl.registerFactory<DepositBloc>(() => DepositBloc(sl<Deposit>()));
  }

  if (!sl.isRegistered<WithdrawBloc>()) {
    sl.registerFactory<WithdrawBloc>(() => WithdrawBloc(sl<Withdraw>()));
  }

  // Home feature
  if (!sl.isRegistered<HomeRemoteDataSource>()) {
    sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(sl<Dio>(), sl()),
    );
  }

  if (!sl.isRegistered<HomeRepository>()) {
    sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(sl<HomeRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<HomeCubit>()) {
    sl.registerFactory<HomeCubit>(() => HomeCubit(sl<HomeRepository>()));
  }

  // Rental feature
  if (!sl.isRegistered<RentalRemoteDataSource>()) {
    sl.registerLazySingleton<RentalRemoteDataSource>(
      () => RentalRemoteDataSourceImpl(sl<Dio>(), sl<UserLocalStorage>()),
    );
  }

  if (!sl.isRegistered<RentalRepository>()) {
    sl.registerLazySingleton<RentalRepository>(
      () => RentalRepositoryImpl(sl<RentalRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<GetRenterBookings>()) {
    sl.registerFactory<GetRenterBookings>(
      () => GetRenterBookings(sl<RentalRepository>()),
    );
  }

  // Owner Booking Management feature
  if (!sl.isRegistered<OwnerBookingRemoteDataSource>()) {
    sl.registerLazySingleton<OwnerBookingRemoteDataSource>(
      () => OwnerBookingRemoteDataSourceImpl(sl<Dio>(), sl()),
    );
  }

  if (!sl.isRegistered<OwnerBookingRepository>()) {
    sl.registerLazySingleton<OwnerBookingRepository>(
      () => OwnerBookingRepositoryImpl(sl<OwnerBookingRemoteDataSource>()),
    );
  }

  if (!sl.isRegistered<OwnerBookingCubit>()) {
    sl.registerFactory<OwnerBookingCubit>(
      () => OwnerBookingCubit(sl<OwnerBookingRepository>()),
    );
  }
}
