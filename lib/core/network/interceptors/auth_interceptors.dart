import 'dart:async';

import 'package:dio/dio.dart';
import '../../model/user_model.dart';
import '../../services/storage_service.dart';
import '../api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  AuthInterceptor(this._storageService);

  // =========================================================
  // ADD ACCESS TOKEN
  // =========================================================

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final accessToken = _storageService.getToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      handler.next(options);
    } catch (e) {
      handler.next(options);
    }
  }

  // =========================================================
  // HANDLE 401
  // =========================================================

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // ---------------------------------------------------------
    // Only handle 401
    // ---------------------------------------------------------

    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // ---------------------------------------------------------
    // Don't refresh login / refresh / logout
    // ---------------------------------------------------------

    final path = err.requestOptions.path;

    if (_isAuthEndpoint(path)) {
      handler.next(err);
      return;
    }

    // ---------------------------------------------------------
    // Check refresh token
    // ---------------------------------------------------------

    final refreshToken = _storageService.getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      // No refresh token means the session
      // cannot be restored.

      await _storageService.clearSession();

      handler.next(err);
      return;
    }

    try {
      // -------------------------------------------------------
      // Refresh token
      // -------------------------------------------------------

      final newAccessToken = await _refreshAccessToken(refreshToken);

      // -------------------------------------------------------
      // Refresh failed
      // -------------------------------------------------------

      if (newAccessToken == null || newAccessToken.isEmpty) {
        handler.next(err);
        return;
      }

      // -------------------------------------------------------
      // Retry original request
      // -------------------------------------------------------

      final requestOptions = err.requestOptions;

      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryDio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await retryDio.fetch(requestOptions);

      handler.resolve(response);
    } on DioException catch (e) {
      // -------------------------------------------------------
      // Retry failed
      // -------------------------------------------------------

      handler.next(e);
    } catch (e) {
      handler.next(err);
    }
  }

  // =========================================================
  // REFRESH ACCESS TOKEN
  // =========================================================

  Future<String?> _refreshAccessToken(String refreshToken) async {
    // ---------------------------------------------------------
    // If another request is already refreshing,
    // wait for it.
    // ---------------------------------------------------------

    if (_isRefreshing) {
      return _refreshCompleter?.future;
    }

    _isRefreshing = true;

    _refreshCompleter = Completer<String?>();

    try {
      // -------------------------------------------------------
      // Separate Dio instance
      // -------------------------------------------------------

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      // -------------------------------------------------------
      // Refresh API
      // -------------------------------------------------------

      final response = await dio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      // -------------------------------------------------------
      // Check response
      // -------------------------------------------------------

      if (response.statusCode != 200 || response.data == null) {
        _refreshCompleter?.complete(null);

        return null;
      }

      // -------------------------------------------------------
      // Parse response
      // -------------------------------------------------------

      final dynamic rawData =
          response.data is Map && response.data.containsKey('data')
              ? response.data['data']
              : response.data;

      final loginResponse = UserModel.fromJson(
        Map<String, dynamic>.from(rawData as Map),
      );

      // -------------------------------------------------------
      // Save new access token
      // -------------------------------------------------------

      if (loginResponse.accessToken.isNotEmpty) {
        await _storageService.saveToken(loginResponse.accessToken);

        // -----------------------------------------------------
        // Save rotated refresh token
        //
        // If backend returns a new refresh token,
        // replace the old one.
        //
        // Otherwise keep the existing refresh token.
        // -----------------------------------------------------

        if (loginResponse.refreshToken != null &&
            loginResponse.refreshToken!.isNotEmpty) {
          await _storageService.saveRefreshToken(loginResponse.refreshToken!);
        }

        // -----------------------------------------------------
        // Update user information if available
        // -----------------------------------------------------

        if (loginResponse.username.isNotEmpty) {
          await _storageService.saveSession(
            token: loginResponse.accessToken,
            refreshToken: loginResponse.refreshToken ?? refreshToken,
            username: loginResponse.username,
            role: loginResponse.role,
            userId: loginResponse.userId,
            memberId: loginResponse.memberId,
          );
        }
      }

      // -------------------------------------------------------
      // Complete waiting requests
      // -------------------------------------------------------

      _refreshCompleter?.complete(loginResponse.accessToken);

      return loginResponse.accessToken;
    } on DioException catch (e) {
      // =====================================================
      // IMPORTANT
      // =====================================================
      //
      // Don't clear session for network/server errors.
      //
      // Example:
      // 500
      // timeout
      // connection error
      //
      // The refresh token may still be valid.
      // =====================================================

      final statusCode = e.response?.statusCode;

      if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
        await _storageService.clearSession();
      }

      _refreshCompleter?.complete(null);

      return null;
    } catch (e) {
      _refreshCompleter?.complete(null);

      return null;
    } finally {
      _isRefreshing = false;

      _refreshCompleter = null;
    }
  }

  // =========================================================
  // AUTH ENDPOINT CHECK
  // =========================================================

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout');
  }
}
