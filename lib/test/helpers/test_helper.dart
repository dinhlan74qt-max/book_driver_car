import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:book_drive_car/features/auth/data/models/auth_result_model.dart';
import 'package:book_drive_car/features/auth/data/models/user_model.dart';
import 'package:book_drive_car/features/auth/domain/entities/auth_result_entity.dart';
import 'package:book_drive_car/features/auth/domain/entities/user_entity.dart';
import 'package:book_drive_car/features/auth/domain/repositories/auth_repository.dart';
import 'package:book_drive_car/features/auth/domain/usecases/login.dart';
import 'package:book_drive_car/features/favorite/data/datasources/favorite_remote_data_source.dart';
import 'package:book_drive_car/features/home/data/models/car_model.dart';
import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/domain/repositories/home_repository.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockLoginUseCase extends Mock implements Login {}
class MockUserLocalStorage extends Mock implements UserLocalStorage {}
class MockHomeRepository extends Mock implements HomeRepository {}
class MockFavoriteRemoteDataSource extends Mock implements FavoriteRemoteDataSource {}

// Test Data
final testUserEntity = UserEntity(
  id: 1,
  fullname: 'Nguyễn Văn A',
  email: 'test@example.com',
  phone: '0901234567',
  role: 'user',
  cccd: '012345678901',
  address: 'Hà Nội',
);

final testUserModel = UserModel(
  id: 1,
  fullname: 'Nguyễn Văn A',
  email: 'test@example.com',
  phone: '0901234567',
  role: 'user',
  cccd: '012345678901',
  address: 'Hà Nội',
);

final testAuthResultEntity = AuthResultEntity(
  token: 'mock_jwt_token_123',
  tokenType: 'Bearer',
  user: testUserEntity,
);

final testAuthResultModel = AuthResultModel(
  token: 'mock_jwt_token_123',
  tokenType: 'Bearer',
  user: testUserModel,
);

const testCarModel = CarModel(
  id: '10',
  name: 'Mazda 3 Luxury',
  brand: 'Mazda',
  vehicleType: 'Sedan',
  province: 'Hà Nội',
  imageIcon: 'https://example.com/mazda3.jpg',
  imageUrls: ['https://example.com/mazda3.jpg'],
  pricePerDay: 800000,
  distanceKm: 2.5,
  seats: 5,
  rating: 4.9,
  location: 'Cầu Giấy, Hà Nội',
  fuelType: 'Xăng',
  transmission: 'Tự động',
);

const testCarEntity = CarEntity(
  id: '10',
  name: 'Mazda 3 Luxury',
  brand: 'Mazda',
  vehicleType: 'Sedan',
  province: 'Hà Nội',
  imageIcon: 'https://example.com/mazda3.jpg',
  imageUrls: ['https://example.com/mazda3.jpg'],
  pricePerDay: 800000,
  distanceKm: 2.5,
  seats: 5,
  rating: 4.9,
  location: 'Cầu Giấy, Hà Nội',
  fuelType: 'Xăng',
  transmission: 'Tự động',
);

Widget makeTestableWidget(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? ThemeData.light(useMaterial3: true),
    home: Scaffold(
      body: child,
    ),
  );
}
