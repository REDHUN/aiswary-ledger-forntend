import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorType type;

  const ApiException({
    required this.message,
    this.statusCode,
    required this.type,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: "Connection timed out. Please check backend server.",
          type: ApiErrorType.timeout,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: "Cannot connect to server at http://localhost:8080.",
          type: ApiErrorType.connectionError,
        );

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response);

      default:
        return ApiException(
          message: _extractServerMessage(error.response, "An unexpected error occurred."),
          type: ApiErrorType.unknown,
        );
    }
  }

  static ApiException _handleStatusCode(Response? response) {
    final statusCode = response?.statusCode;
    final message = _extractServerMessage(response, "Request failed");

    switch (statusCode) {
      case 400:
        return ApiException(message: message, statusCode: statusCode, type: ApiErrorType.badRequest);
      case 401:
        return ApiException(message: "Invalid credentials or session expired.", statusCode: statusCode, type: ApiErrorType.unauthorized);
      case 403:
        return ApiException(message: "Access denied.", statusCode: statusCode, type: ApiErrorType.forbidden);
      case 404:
        return ApiException(message: message, statusCode: statusCode, type: ApiErrorType.notFound);
      case 422:
        return ApiException(message: message, statusCode: statusCode, type: ApiErrorType.validation);
      case 500:
        return ApiException(message: "Server error: $message", statusCode: statusCode, type: ApiErrorType.server);
      default:
        return ApiException(message: message, statusCode: statusCode, type: ApiErrorType.unknown);
    }
  }

  static String _extractServerMessage(Response? response, String defaultMessage) {
    if (response?.data is Map<String, dynamic>) {
      final map = response!.data as Map<String, dynamic>;

      if (map['error'] is Map && map['error']['message'] != null && map['error']['message'].toString().trim().isNotEmpty) {
        return map['error']['message'].toString();
      }

      if (map['error'] is String && map['error'].toString().trim().isNotEmpty) {
        return map['error'].toString();
      }

      if (map['message'] != null && map['message'].toString().trim().isNotEmpty) {
        return map['message'].toString();
      }
    }
    return defaultMessage;
  }


  @override
  String toString() => message;
}

enum ApiErrorType {
  timeout,
  connectionError,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  unknown,
}
