import 'package:book_drive_car/features/home/domain/entities/car_entity.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_cubit.dart';
import 'package:book_drive_car/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helper.dart';

void main() {
  late MockHomeRepository mockHomeRepository;
  late HomeCubit homeCubit;

  setUp(() {
    mockHomeRepository = MockHomeRepository();
    homeCubit = HomeCubit(mockHomeRepository);
  });

  tearDown(() {
    homeCubit.close();
  });

  const carFarHighRating = CarEntity(
    id: '1',
    name: 'Xe Xa Đánh Giá Cao',
    brand: 'Toyota',
    vehicleType: 'Sedan',
    province: 'Hà Nội',
    imageIcon: '',
    imageUrls: [],
    pricePerDay: 700000,
    distanceKm: 15.0, // Xa
    seats: 4,
    rating: 5.0, // Đánh giá cao
    location: 'Hà Nội',
  );

  const carNearLowRating = CarEntity(
    id: '2',
    name: 'Xe Gần Đánh Giá Thấp',
    brand: 'Hyundai',
    vehicleType: 'Hatchback',
    province: 'Hà Nội',
    imageIcon: '',
    imageUrls: [],
    pricePerDay: 500000,
    distanceKm: 1.2, // Gần
    seats: 4,
    rating: 4.2, // Đánh giá thấp hơn
    location: 'Hà Nội',
  );

  test('trạng thái ban đầu phải là HomeInitial', () {
    expect(homeCubit.state, isA<HomeInitial>());
  });

  group('HomeCubit - fetchCars', () {
    test('nên phát ra [HomeLoading, HomeLoaded] với danh sách đã sắp xếp đúng khoảng cách và đánh giá', () async {
      when(() => mockHomeRepository.getCars())
          .thenAnswer((_) async => [carFarHighRating, carNearLowRating]);

      final expectedStates = [
        isA<HomeLoading>(),
        isA<HomeLoaded>().having((s) {
          // nearbyCars phải sắp xếp theo distanceKm tăng dần (xe 2 trước xe 1)
          final isNearbySorted = s.nearbyCars.first.id == '2' && s.nearbyCars.last.id == '1';
          // suggestedCars phải sắp xếp theo rating giảm dần (xe 1 trước xe 2)
          final isSuggestedSorted = s.suggestedCars.first.id == '1' && s.suggestedCars.last.id == '2';
          return isNearbySorted && isSuggestedSorted;
        }, 'đã sắp xếp xe gần nhất và xe đánh giá cao nhất', isTrue),
      ];

      expectLater(homeCubit.stream, emitsInOrder(expectedStates));

      await homeCubit.fetchCars();
    });

    test('nên phát ra [HomeLoading, HomeError] khi repository ném ngoại lệ', () async {
      when(() => mockHomeRepository.getCars())
          .thenThrow(Exception('Không thể kết nối đến máy chủ'));

      final expectedStates = [
        isA<HomeLoading>(),
        isA<HomeError>().having(
          (s) => s.message,
          'message',
          contains('Không thể kết nối đến máy chủ'),
        ),
      ];

      expectLater(homeCubit.stream, emitsInOrder(expectedStates));

      await homeCubit.fetchCars();
    });
  });

  group('HomeCubit - searchCars', () {
    test('nên phát ra [HomeLoading, HomeLoaded] khi tìm kiếm thành công', () async {
      when(() => mockHomeRepository.searchCars(
            locationMode: any(named: 'locationMode'),
            locationLabel: any(named: 'locationLabel'),
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            vehicleType: any(named: 'vehicleType'),
            brand: any(named: 'brand'),
            model: any(named: 'model'),
            minPrice: any(named: 'minPrice'),
            maxPrice: any(named: 'maxPrice'),
            minSeats: any(named: 'minSeats'),
            maxSeats: any(named: 'maxSeats'),
            city: any(named: 'city'),
          )).thenAnswer((_) async => [testCarEntity]);

      final expectedStates = [
        isA<HomeLoading>(),
        isA<HomeLoaded>().having((s) => s.cars.length, 'số lượng xe', 1),
      ];

      expectLater(homeCubit.stream, emitsInOrder(expectedStates));

      await homeCubit.searchCars(brand: 'Mazda');
    });
  });
}
