import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class UserSecurityRemoteDataSource {
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}

class UserSecurityRemoteDataSourceImpl implements UserSecurityRemoteDataSource {
  final Dio dio;
  final UserLocalStorage userLocalStorage;

  UserSecurityRemoteDataSourceImpl(this.dio, this.userLocalStorage);

  @override
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final authHeader = await userLocalStorage.getAuthHeader();
    final payload = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };

    final candidateUrls = [
      ApiConstants.changePassword,
      'http://192.168.1.52:8080/api/users/me/password',
      'http://10.0.2.2:8080/api/users/me/password',
      'http://localhost:8080/api/users/me/password',
    ];

    Response? lastResponse;
    String? lastErrorMessage;

    for (final url in candidateUrls) {
      debugPrint(
        '[UserSecurityRemoteDataSource][changePassword] PUT $url payload={currentPassword: ***, newPassword: ***, confirmPassword: ***}',
      );

      try {
        final response = await dio.put(
          url,
          data: payload,
          options: Options(
            headers: {
              if (authHeader != null) 'Authorization': authHeader,
              'Content-Type': 'application/json',
            },
            connectTimeout: const Duration(seconds: 4),
            sendTimeout: const Duration(seconds: 4),
            receiveTimeout: const Duration(seconds: 4),
            validateStatus: (_) => true,
          ),
        );

        lastResponse = response;
        debugPrint(
          '[UserSecurityRemoteDataSource][changePassword] HTTP ${response.statusCode} data=${response.data}',
        );

        final data = response.data;
        String message = 'Đổi mật khẩu thành công';
        if (data is Map<String, dynamic>) {
          message = data['message']?.toString() ??
              data['error']?.toString() ??
              data['detail']?.toString() ??
              message;
        } else if (data is String && data.isNotEmpty) {
          message = data;
        }

        if (response.statusCode == 200 || response.statusCode == 204) {
          return message;
        }

        // Nếu là 404 (chưa có endpoint trên server này) hoặc 405, tiếp tục thử url tiếp theo
        if (response.statusCode == 404 || response.statusCode == 405) {
          lastErrorMessage = message;
          continue;
        }

        // Lỗi nghiệp vụ khác (ví dụ: 400 mật khẩu cũ không đúng, 401 hết hạn token), ném lỗi luôn
        throw Exception(message);
      } on DioException catch (e) {
        debugPrint(
          '[UserSecurityRemoteDataSource][changePassword] Failed on $url: $e',
        );
        continue;
      }
    }

    if (lastResponse?.statusCode == 404) {
      throw Exception(
        'Server thuexetulai.click:8080 chưa cập nhật endpoint đổi mật khẩu. Hãy khởi động backend ở máy tính (http://192.168.1.52:8080) hoặc deploy bản mới lên server.',
      );
    }

    throw Exception(
      lastErrorMessage ?? 'Không thể kết nối đến máy chủ để đổi mật khẩu',
    );
  }
}
