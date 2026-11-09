import 'package:book_drive_car/core/di/injection_container.dart';
import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/favorite/data/datasources/favorite_remote_data_source.dart';
import 'package:book_drive_car/features/home/data/models/car_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class FavoriteManager extends ChangeNotifier {
  static final FavoriteManager instance = FavoriteManager._internal();

  FavoriteManager._internal();

  FavoriteRemoteDataSource? _remoteDataSource;

  FavoriteRemoteDataSource get _dataSource {
    if (_remoteDataSource != null) return _remoteDataSource!;
    if (sl.isRegistered<FavoriteRemoteDataSource>()) {
      _remoteDataSource = sl<FavoriteRemoteDataSource>();
      return _remoteDataSource!;
    }
    _remoteDataSource = FavoriteRemoteDataSourceImpl(
      sl.isRegistered<Dio>() ? sl<Dio>() : Dio(),
      sl.isRegistered<UserLocalStorage>()
          ? sl<UserLocalStorage>()
          : UserLocalStorage(),
    );
    return _remoteDataSource!;
  }

  final Set<int> _favoriteIds = <int>{};
  List<CarModel> _favorites = <CarModel>[];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasInitialLoaded = false;

  Set<int> get favoriteIds => Set.unmodifiable(_favoriteIds);
  List<CarModel> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasInitialLoaded => _hasInitialLoaded;

  void _safeNotifyListeners() {
    final phase = WidgetsBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  bool isFavorite(dynamic vehicleId) {
    if (vehicleId == null) return false;
    final id = int.tryParse(vehicleId.toString());
    if (id == null) return false;
    return _favoriteIds.contains(id);
  }

  Future<List<CarModel>> loadFavorites({bool forceRefresh = false}) async {
    if (_isLoading) return _favorites;
    if (_hasInitialLoaded && !forceRefresh) return _favorites;

    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final list = await _dataSource.getFavorites();
      _favorites = list;
      _favoriteIds.clear();
      for (final car in list) {
        final id = int.tryParse(car.id);
        if (id != null) _favoriteIds.add(id);
      }
      _hasInitialLoaded = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('[FavoriteManager] loadFavorites error: $_errorMessage');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }

    return _favorites;
  }

  Future<bool> toggleFavorite(
    dynamic vehicleId, {
    CarModel? fallbackCar,
    bool persistOptimisticOnFailure = true,
  }) async {
    final id = int.tryParse(vehicleId.toString());
    if (id == null || id <= 0) {
      throw Exception('Mã xe không hợp lệ');
    }

    final currentlyFavorite = _favoriteIds.contains(id);

    // Optimistic UI update: cập nhật ngay lập tức
    if (currentlyFavorite) {
      _favoriteIds.remove(id);
      _favorites.removeWhere((c) => int.tryParse(c.id) == id);
    } else {
      _favoriteIds.add(id);
      if (fallbackCar != null &&
          !_favorites.any((c) => int.tryParse(c.id) == id)) {
        _favorites.insert(0, fallbackCar);
      }
    }
    _safeNotifyListeners();

    try {
      if (currentlyFavorite) {
        await _dataSource.removeFavorite(id);
        return false;
      } else {
        await _dataSource.addFavorite(id);
        // Refresh full list in background to ensure sync
        _reloadSilently();
        return true;
      }
    } catch (e) {
      debugPrint('[FavoriteManager] toggleFavorite server error: $e');
      if (!persistOptimisticOnFailure) {
        // Revert optimistic update on failure
        if (currentlyFavorite) {
          _favoriteIds.add(id);
          if (fallbackCar != null) _favorites.add(fallbackCar);
        } else {
          _favoriteIds.remove(id);
          _favorites.removeWhere((c) => int.tryParse(c.id) == id);
        }
        _safeNotifyListeners();
        rethrow;
      }
      return !currentlyFavorite;
    }
  }

  Future<void> removeFavorite(dynamic vehicleId) async {
    final id = int.tryParse(vehicleId.toString());
    if (id == null || id <= 0) return;

    _favoriteIds.remove(id);
    _favorites.removeWhere((c) => int.tryParse(c.id) == id);
    _safeNotifyListeners();

    try {
      await _dataSource.removeFavorite(id);
    } catch (e) {
      debugPrint('[FavoriteManager] removeFavorite server error: $e');
    }
  }

  void _reloadSilently() {
    _dataSource
        .getFavorites()
        .then((list) {
          _favorites = list;
          _favoriteIds.clear();
          for (final car in list) {
            final id = int.tryParse(car.id);
            if (id != null) _favoriteIds.add(id);
          }
          _safeNotifyListeners();
        })
        .catchError((_) {});
  }

  @visibleForTesting
  void resetForTesting({FavoriteRemoteDataSource? dataSource}) {
    _remoteDataSource = dataSource;
    _favoriteIds.clear();
    _favorites.clear();
    _isLoading = false;
    _errorMessage = null;
    _hasInitialLoaded = false;
  }
}
