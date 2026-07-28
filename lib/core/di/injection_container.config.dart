// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:book_drive_car/core/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i9;
import 'package:book_drive_car/core/features/auth/data/repositories/auth_repository_impl.dart'
    as _i405;
import 'package:book_drive_car/core/features/auth/domain/repositories/auth_repository.dart'
    as _i574;
import 'package:book_drive_car/core/features/auth/domain/usecases/send_otp.dart'
    as _i579;
import 'package:book_drive_car/core/features/auth/presentation/bloc/send_otp_bloc.dart'
    as _i583;
import 'package:book_drive_car/core/di/injectable_modules.dart' as _i343;
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
    gh.lazySingleton<_i9.AuthRemoteDataSource>(
      () => _i9.AuthRemoteDataSourceImpl(gh<_i519.Client>()),
    );
    gh.lazySingleton<_i574.AuthRepository>(
      () => _i405.AuthRepositoryImpl(gh<_i9.AuthRemoteDataSource>()),
    );
    gh.factory<_i579.SendOtp>(() => _i579.SendOtp(gh<_i574.AuthRepository>()));
    gh.factory<_i583.SendOtpBloc>(() => _i583.SendOtpBloc(gh<_i579.SendOtp>()));
    return this;
  }
}

class _$RegisterModule extends _i343.RegisterModule {}
