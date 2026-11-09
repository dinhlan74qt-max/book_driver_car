import 'package:book_drive_car/features/favorite/presentation/manager/favorite_manager.dart';
import 'package:book_drive_car/features/home/data/models/car_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFavoriteRemoteDataSource mockDataSource;
  late FavoriteManager manager;

  setUp(() {
    mockDataSource = MockFavoriteRemoteDataSource();
    when(() => mockDataSource.getFavorites()).thenAnswer((_) async => <CarModel>[]);
    when(() => mockDataSource.addFavorite(any())).thenAnswer((_) async => 'Đã thêm xe vào danh sách yêu thích');
    when(() => mockDataSource.removeFavorite(any())).thenAnswer((_) async => 'Đã xóa xe khỏi danh sách yêu thích');
    manager = FavoriteManager.instance;
    manager.resetForTesting(dataSource: mockDataSource);
  });

  group('FavoriteManager - isFavorite', () {
    test('nên trả về false khi vehicleId là null hoặc không hợp lệ', () {
      expect(manager.isFavorite(null), isFalse);
      expect(manager.isFavorite('abc'), isFalse);
      expect(manager.isFavorite(0), isFalse);
    });

    test('nên trả về true khi xe đã nằm trong danh sách yêu thích', () async {
      await manager.toggleFavorite(10, fallbackCar: testCarModel);
      expect(manager.isFavorite(10), isTrue);
      expect(manager.isFavorite('10'), isTrue);
    });
  });

  group('FavoriteManager - loadFavorites', () {
    test('nên nạp danh sách xe và cập nhật favoriteIds thành công', () async {
      when(() => mockDataSource.getFavorites()).thenAnswer((_) async => [testCarModel]);

      final result = await manager.loadFavorites(forceRefresh: true);

      expect(result.length, equals(1));
      expect(manager.favorites.length, equals(1));
      expect(manager.favoriteIds.contains(10), isTrue);
      expect(manager.isLoading, isFalse);
      expect(manager.errorMessage, isNull);
      verify(() => mockDataSource.getFavorites()).called(1);
    });

    test('nên bắt lỗi và lưu errorMessage khi API getFavorites ném ngoại lệ', () async {
      when(() => mockDataSource.getFavorites()).thenThrow(Exception('Lỗi máy chủ 500'));

      final result = await manager.loadFavorites(forceRefresh: true);

      expect(result, isEmpty);
      expect(manager.errorMessage, contains('Lỗi máy chủ 500'));
      expect(manager.isLoading, isFalse);
    });
  });

  group('FavoriteManager - toggleFavorite & removeFavorite', () {
    test('nên thêm xe vào yêu thích ngay tức thì (Optimistic UI)', () async {
      final isNowFav = await manager.toggleFavorite(10, fallbackCar: testCarModel);

      expect(isNowFav, isTrue);
      expect(manager.isFavorite(10), isTrue);
      expect(manager.favorites.any((c) => c.id == '10'), isTrue);
      verify(() => mockDataSource.addFavorite(10)).called(1);
    });

    test('nên xóa xe khỏi yêu thích khi gọi toggleFavorite lần 2', () async {
      // Thêm lần 1
      await manager.toggleFavorite(10, fallbackCar: testCarModel);
      expect(manager.isFavorite(10), isTrue);

      // Nhấn lần 2 -> Xóa
      final isNowFav = await manager.toggleFavorite(10);
      expect(isNowFav, isFalse);
      expect(manager.isFavorite(10), isFalse);
      verify(() => mockDataSource.removeFavorite(10)).called(1);
    });

    test('nên xóa xe trực tiếp khi gọi removeFavorite', () async {
      await manager.toggleFavorite(10, fallbackCar: testCarModel);
      expect(manager.isFavorite(10), isTrue);

      await manager.removeFavorite(10);
      expect(manager.isFavorite(10), isFalse);
      expect(manager.favorites.isEmpty, isTrue);
      verify(() => mockDataSource.removeFavorite(10)).called(1);
    });

    test('nên giữ lại trạng thái optimistic khi server lỗi nếu persistOptimisticOnFailure = true', () async {
      when(() => mockDataSource.addFavorite(20)).thenThrow(Exception('Lỗi mạng hoặc server'));

      final isFav = await manager.toggleFavorite(
        20,
        fallbackCar: testCarModel,
        persistOptimisticOnFailure: true,
      );

      // Vẫn giữ tim đỏ cục bộ cho người dùng
      expect(isFav, isTrue);
      expect(manager.isFavorite(20), isTrue);
    });

    test('nên rollback trạng thái optimistic và ném lỗi khi server lỗi nếu persistOptimisticOnFailure = false', () async {
      when(() => mockDataSource.addFavorite(30)).thenThrow(Exception('Không thể kết nối đến server'));

      expect(
        () => manager.toggleFavorite(
          30,
          fallbackCar: testCarModel,
          persistOptimisticOnFailure: false,
        ),
        throwsA(isA<Exception>()),
      );

      // Đã rollback trạng thái, không còn trong favorite
      expect(manager.isFavorite(30), isFalse);
      expect(manager.favorites.any((c) => c.id == '30'), isFalse);
    });
  });
}
