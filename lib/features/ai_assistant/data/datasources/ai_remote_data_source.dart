import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:book_drive_car/core/storage/user_local_storage.dart';
import 'package:book_drive_car/features/ai_assistant/data/models/ai_response_model.dart';
import 'package:book_drive_car/shared/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

abstract class AiRemoteDataSource {
  Future<AiResponseModel> sendChatMessage(String message);
}

@LazySingleton(as: AiRemoteDataSource)
class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final Dio dio;
  final UserLocalStorage userLocalStorage;

  AiRemoteDataSourceImpl(this.dio, this.userLocalStorage);

  Future<Options> _buildOptions() async {
    final authHeader = await userLocalStorage.getAuthHeader();
    return Options(
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        if (authHeader != null && authHeader.trim().isNotEmpty)
          'Authorization': authHeader,
      },
      sendTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 90),
      validateStatus: (status) => status != null && status < 500,
    );
  }

  @override
  Future<AiResponseModel> sendChatMessage(String message) async {
    final requestBody = {'message': message};
    final options = await _buildOptions();

    // Danh sách URL ưu tiên:
    // 1. ApiConstants.aiChat (Cấu hình chính theo server/IP)
    // 2. Fallback localhost / emulator nếu đang chạy Spring Boot tại local
    final candidateUrls = <String>[
      ApiConstants.aiChat,
      if (!ApiConstants.aiChat.contains('localhost') &&
          !ApiConstants.aiChat.contains('10.0.2.2')) ...[
        if (!kIsWeb && Platform.isAndroid)
          'http://10.0.2.2:8080/api/ai/chat'
        else
          'http://localhost:8080/api/ai/chat',
      ],
    ];

    DioException? lastDioException;
    Object? lastError;

    for (final url in candidateUrls) {
      try {
        debugPrint('🚀 [AI Assistant] Sending POST to: $url');
        final response = await dio.post(
          url,
          data: requestBody,
          options: options,
        );

        debugPrint(
            '📥 [AI Assistant] Response status: ${response.statusCode}');
        debugPrint(
            '📥 [AI Assistant] Response data: ${response.data}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            return AiResponseModel.fromJson(data);
          } else if (data is Map) {
            return AiResponseModel.fromJson(Map<String, dynamic>.from(data));
          } else if (data is String) {
            final decoded = jsonDecode(data);
            if (decoded is Map<String, dynamic>) {
              return AiResponseModel.fromJson(decoded);
            }
          }
          throw Exception('Định dạng dữ liệu từ AI server không hợp lệ.');
        } else {
          final errorMsg = _extractErrorMessage(
            response.data,
            fallback: 'Máy chủ phản hồi mã lỗi ${response.statusCode}.',
          );
          throw Exception(errorMsg);
        }
      } on DioException catch (e) {
        lastDioException = e;
        debugPrint('⚠️ [AI Assistant] DioException on $url: ${e.message}');
        // Nếu lỗi kết nối (Connection refused), thử URL tiếp theo trong candidateUrls
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout) {
          continue;
        }
        break;
      } catch (e) {
        lastError = e;
        debugPrint('⚠️ [AI Assistant] Error on $url: $e');
        break;
      }
    }

    if (lastDioException != null) {
      throw Exception(_friendlyDioMessage(lastDioException));
    }

    if (lastError != null) {
      throw Exception(lastError.toString().replaceFirst('Exception: ', ''));
    }

    throw Exception('Không thể kết nối tới dịch vụ AI trợ lý xe.');
  }

  String _extractErrorMessage(dynamic data, {required String fallback}) {
    if (data is Map<String, dynamic>) {
      final msg =
          data['message'] ?? data['reply'] ?? data['error'] ?? data['detail'];
      if (msg is String && msg.trim().isNotEmpty) {
        return msg;
      }
    } else if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    return fallback;
  }

  String _friendlyDioMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Phản hồi từ AI mất nhiều thời gian hơn dự kiến. Vui lòng thử lại sau ít giây!';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối đến máy chủ AI (Spring Boot). Hãy kiểm tra kết nối mạng hoặc trạng thái máy chủ.';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        return 'Máy chủ phản hồi lỗi ($code). Vui lòng thử lại!';
      case DioExceptionType.cancel:
        return 'Yêu cầu tới AI đã bị hủy.';
      default:
        return e.message ?? 'Đã xảy ra lỗi khi gửi yêu cầu tới AI.';
    }
  }
}
