// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:book_drive_car/core/di/injectable_modules.dart' as _i172;
import 'package:book_drive_car/core/storage/user_local_storage.dart' as _i771;
import 'package:book_drive_car/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i1048;
import 'package:book_drive_car/features/auth/data/repositories/auth_repository_impl.dart'
    as _i450;
import 'package:book_drive_car/features/auth/domain/repositories/auth_repository.dart'
    as _i181;
import 'package:book_drive_car/features/auth/domain/usecases/login.dart'
    as _i1030;
import 'package:book_drive_car/features/auth/domain/usecases/send_otp.dart'
    as _i841;
import 'package:book_drive_car/features/auth/presentation/bloc/login_bloc.dart'
    as _i259;
import 'package:book_drive_car/features/auth/presentation/bloc/send_otp_bloc.dart'
    as _i595;
import 'package:book_drive_car/features/home/data/datasources/booking_remote_data_source.dart'
    as _i617;
import 'package:book_drive_car/features/home/data/datasources/home_remote_data_source.dart'
    as _i65;
import 'package:book_drive_car/features/home/data/repositories/home_repository_impl.dart'
    as _i815;
import 'package:book_drive_car/features/home/domain/repositories/booking_repository.dart'
    as _i7;
import 'package:book_drive_car/features/home/domain/repositories/home_repository.dart'
    as _i827;
import 'package:book_drive_car/features/home/domain/usercases/create_booking.dart'
    as _i862;
import 'package:book_drive_car/features/home/presentation/bloc/booking_bloc.dart'
    as _i657;
import 'package:book_drive_car/features/home/presentation/bloc/home_cubit.dart'
    as _i310;
import 'package:book_drive_car/features/profile/data/datasources/owner_booking_remote_data_source.dart'
    as _i950;
import 'package:book_drive_car/features/profile/data/datasources/vehicle_remote_data_source.dart'
    as _i976;
import 'package:book_drive_car/features/profile/data/repositories/owner_booking_repository_impl.dart'
    as _i9;
import 'package:book_drive_car/features/profile/data/repositories/vehicle_repository_impl.dart'
    as _i348;
import 'package:book_drive_car/features/profile/domain/repositories/owner_booking_repository.dart'
    as _i249;
import 'package:book_drive_car/features/profile/domain/repositories/vehicle_repository.dart'
    as _i210;
import 'package:book_drive_car/features/profile/domain/usecases/add_vehicle.dart'
    as _i439;
import 'package:book_drive_car/features/profile/domain/usecases/get_my_vehicles.dart'
    as _i875;
import 'package:book_drive_car/features/profile/presentation/bloc/add_vehicle_bloc.dart'
    as _i21;
import 'package:book_drive_car/features/profile/presentation/bloc/my_vehicles_bloc.dart'
    as _i141;
import 'package:book_drive_car/features/profile/presentation/bloc/owner_booking_cubit.dart'
    as _i167;
import 'package:book_drive_car/features/rental/data/datasources/rental_remote_data_source.dart'
    as _i155;
import 'package:book_drive_car/features/rental/data/repositories/rental_repository_impl.dart'
    as _i29;
import 'package:book_drive_car/features/rental/domain/repositories/rental_repository.dart'
    as _i1067;
import 'package:book_drive_car/features/rental/domain/usecases/get_renter_bookings.dart'
    as _i407;
import 'package:book_drive_car/features/wallet/data/datasources/wallet_remote_data_source.dart'
    as _i487;
import 'package:book_drive_car/features/wallet/data/repositories/wallet_repository_impl.dart'
    as _i392;
import 'package:book_drive_car/features/wallet/domain/repositories/wallet_repository.dart'
    as _i579;
import 'package:book_drive_car/features/wallet/domain/usecases/deposit.dart'
    as _i419;
import 'package:book_drive_car/features/wallet/domain/usecases/get_my_wallet.dart'
    as _i983;
import 'package:book_drive_car/features/wallet/domain/usecases/withdraw.dart'
    as _i972;
import 'package:book_drive_car/features/wallet/presentation/bloc/deposit_bloc.dart'
    as _i1013;
import 'package:book_drive_car/features/wallet/presentation/bloc/wallet_bloc.dart'
    as _i110;
import 'package:book_drive_car/features/wallet/presentation/bloc/withdraw_bloc.dart'
    as _i96;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i519.Client>(() => registerModule.httpClient);
    gh.lazySingleton<_i771.UserLocalStorage>(() => _i771.UserLocalStorage());
    gh.lazySingleton<_i487.WalletRemoteDataSource>(
      () => _i487.WalletRemoteDataSourceImpl(
        gh<_i361.Dio>(),
        gh<_i771.UserLocalStorage>(),
      ),
    );
    gh.factory<_i862.CreateBooking>(
      () => _i862.CreateBooking(gh<_i7.BookingRepository>()),
    );
    gh.lazySingleton<_i1048.AuthRemoteDataSource>(
      () => _i1048.AuthRemoteDataSourceImpl(gh<_i519.Client>()),
    );
    gh.lazySingleton<_i950.OwnerBookingRemoteDataSource>(
      () => _i950.OwnerBookingRemoteDataSourceImpl(
        gh<_i361.Dio>(),
        gh<_i771.UserLocalStorage>(),
      ),
    );
    gh.lazySingleton<_i65.HomeRemoteDataSource>(
      () => _i65.HomeRemoteDataSourceImpl(
        gh<_i361.Dio>(),
        gh<_i771.UserLocalStorage>(),
      ),
    );
    gh.lazySingleton<_i617.BookingRemoteDataSource>(
      () => _i617.BookingRemoteDataSourceImpl(
        gh<_i361.Dio>(),
        gh<_i771.UserLocalStorage>(),
      ),
    );
    gh.lazySingleton<_i976.VehicleRemoteDataSource>(
      () => _i976.VehicleRemoteDataSourceImpl(
        gh<_i361.Dio>(),
        gh<_i771.UserLocalStorage>(),
      ),
    );
    gh.lazySingleton<_i827.HomeRepository>(
      () => _i815.HomeRepositoryImpl(gh<_i65.HomeRemoteDataSource>()),
    );
    gh.lazySingleton<_i249.OwnerBookingRepository>(
      () => _i9.OwnerBookingRepositoryImpl(
        gh<_i950.OwnerBookingRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i155.RentalRemoteDataSource>(
      () => _i155.RentalRemoteDataSourceImpl(
        gh<_i361.Dio>(),
        gh<_i771.UserLocalStorage>(),
      ),
    );
    gh.factory<_i310.HomeCubit>(
      () => _i310.HomeCubit(gh<_i827.HomeRepository>()),
    );
    gh.factory<_i167.OwnerBookingCubit>(
      () => _i167.OwnerBookingCubit(gh<_i249.OwnerBookingRepository>()),
    );
    gh.lazySingleton<_i579.WalletRepository>(
      () => _i392.WalletRepositoryImpl(gh<_i487.WalletRemoteDataSource>()),
    );
    gh.factory<_i657.BookingBloc>(
      () => _i657.BookingBloc(gh<_i862.CreateBooking>()),
    );
    gh.lazySingleton<_i181.AuthRepository>(
      () => _i450.AuthRepositoryImpl(gh<_i1048.AuthRemoteDataSource>()),
    );
    gh.factory<_i1030.Login>(() => _i1030.Login(gh<_i181.AuthRepository>()));
    gh.factory<_i841.SendOtp>(() => _i841.SendOtp(gh<_i181.AuthRepository>()));
    gh.lazySingleton<_i210.VehicleRepository>(
      () => _i348.VehicleRepositoryImpl(gh<_i976.VehicleRemoteDataSource>()),
    );
    gh.factory<_i595.SendOtpBloc>(() => _i595.SendOtpBloc(gh<_i841.SendOtp>()));
    gh.factory<_i439.AddVehicle>(
      () => _i439.AddVehicle(gh<_i210.VehicleRepository>()),
    );
    gh.factory<_i875.GetMyVehicles>(
      () => _i875.GetMyVehicles(gh<_i210.VehicleRepository>()),
    );
    gh.factory<_i110.WalletBloc>(
      () => _i110.WalletBloc(gh<_i579.WalletRepository>()),
    );
    gh.factory<_i21.AddVehicleBloc>(
      () => _i21.AddVehicleBloc(gh<_i439.AddVehicle>()),
    );
    gh.lazySingleton<_i1067.RentalRepository>(
      () => _i29.RentalRepositoryImpl(gh<_i155.RentalRemoteDataSource>()),
    );
    gh.factory<_i259.LoginBloc>(
      () => _i259.LoginBloc(gh<_i1030.Login>(), gh<_i771.UserLocalStorage>()),
    );
    gh.factory<_i419.Deposit>(
      () => _i419.Deposit(gh<_i579.WalletRepository>()),
    );
    gh.factory<_i983.GetMyWallet>(
      () => _i983.GetMyWallet(gh<_i579.WalletRepository>()),
    );
    gh.factory<_i972.Withdraw>(
      () => _i972.Withdraw(gh<_i579.WalletRepository>()),
    );
    gh.factory<_i407.GetRenterBookings>(
      () => _i407.GetRenterBookings(gh<_i1067.RentalRepository>()),
    );
    gh.factory<_i141.MyVehiclesBloc>(
      () => _i141.MyVehiclesBloc(gh<_i875.GetMyVehicles>()),
    );
    gh.factory<_i96.WithdrawBloc>(
      () => _i96.WithdrawBloc(gh<_i972.Withdraw>()),
    );
    gh.factory<_i1013.DepositBloc>(
      () => _i1013.DepositBloc(gh<_i419.Deposit>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i172.RegisterModule {}
