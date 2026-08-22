import 'package:dio/dio.dart';
import 'api_exception.dart';

enum RequestType { get, post, put, delete }

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<dynamic> request({
    required String path,
    required RequestType method,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    Map<String, dynamic>? headers,
  }) async {
    final options = Options(headers: headers);

    try {
      Response response;
      switch (method) {
        case RequestType.get:
          response = await _dio.get(path, queryParameters: queryParameters, options: options);
          break;
        case RequestType.post:
          response = await _dio.post(path, data: body, queryParameters: queryParameters, options: options);
          break;
        case RequestType.put:
          response = await _dio.put(path, data: body, queryParameters: queryParameters, options: options);
          break;
        case RequestType.delete:
          response = await _dio.delete(path, data: body, queryParameters: queryParameters, options: options);
          break;
      }
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString(), type: ApiErrorType.unknown);
    }
  }
}
