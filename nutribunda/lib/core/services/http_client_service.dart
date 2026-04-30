import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'secure_storage_service.dart';

/// Service untuk mengelola HTTP client dengan Dio
/// Menyediakan interceptors untuk autentikasi, error handling, dan logging
class HttpClientService {
  late final Dio _dio;
  final SecureStorageService _secureStorage;

  HttpClientService({
    required SecureStorageService secureStorage,
    Dio? dio,
  }) : _secureStorage = secureStorage {
    _dio = dio ?? Dio();
    _configureDio();
    _setupInterceptors();
  }

  /// Konfigurasi dasar Dio
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        // Accept all status codes to handle them in interceptors
        return status != null && status < 500;
      },
    );
  }

  /// Setup interceptors untuk autentikasi dan error handling
  /// Requirements: 1.6 - Middleware JWT untuk proteksi endpoint
  void _setupInterceptors() {
    _dio.interceptors.clear();

    // Request Interceptor - Menambahkan JWT token ke header
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token untuk endpoint auth
          if (_isAuthEndpoint(options.path)) {
            return handler.next(options);
          }

          // Tambahkan JWT token ke header
          final token = await _secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log successful responses in debug mode
          _logResponse(response);
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Handle errors
          _logError(error);

          // Handle 401 Unauthorized - Token expired
          if (error.response?.statusCode == 401) {
            // Attempt to refresh token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request
              try {
                final response = await _retry(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.reject(error);
              }
            } else {
              // Token refresh failed, clear tokens
              await _secureStorage.deleteTokens();
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: UnauthorizedException('Session expired. Please login again.'),
                  type: DioExceptionType.badResponse,
                ),
              );
            }
          }

          return handler.next(error);
        },
      ),
    );

    // Logging Interceptor (only in debug mode)
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) {
        // Only log in debug mode
        // print(obj);
      },
    ));
  }

  /// Memeriksa apakah endpoint adalah auth endpoint
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');
  }

  /// Refresh JWT token
  /// Requirements: 1.6 - Automatic token refresh
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['token'] as String?;
        if (newAccessToken != null) {
          await _secureStorage.saveAccessToken(newAccessToken);
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Retry request dengan token baru
  Future<Response> _retry(RequestOptions requestOptions) async {
    final token = await _secureStorage.getAccessToken();
    requestOptions.headers['Authorization'] = 'Bearer $token';

    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Log response untuk debugging
  void _logResponse(Response response) {
    // Implement logging if needed
    // print('Response [${response.statusCode}]: ${response.requestOptions.path}');
  }

  /// Log error untuk debugging
  void _logError(DioException error) {
    // Implement error logging if needed
    // print('Error [${error.response?.statusCode}]: ${error.requestOptions.path}');
  }

  // ==================== HTTP Methods ====================

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file dengan multipart/form-data
  Future<Response> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final fileName = File(filePath).uri.pathSegments.last;
      
      // Tentukan tipe konten berdasarkan ekstensi file
      final ext = fileName.split('.').last.toLowerCase();
      MediaType? contentType;
      if (ext == 'png') {
        contentType = MediaType('image', 'png');
      } else if (ext == 'jpg' || ext == 'jpeg') {
        contentType = MediaType('image', 'jpeg');
      }

      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: contentType,
        ),
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download file
  Future<Response> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Response & Error Handling ====================

  /// Handle response berdasarkan status code
  Response _handleResponse(Response response) {
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      return response;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized access');
    } else if (response.statusCode == 400) {
      throw ValidationException(
        response.data['message'] ?? 'Validation error',
      );
    } else if (response.statusCode == 404) {
      throw ServerException('Resource not found');
    } else {
      throw ServerException(
        response.data['message'] ?? 'Server error occurred',
      );
    }
  }

  /// Handle Dio errors dan convert ke custom exceptions
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] as String?;

        if (statusCode == 401) {
          return UnauthorizedException(message ?? 'Unauthorized access');
        } else if (statusCode == 400) {
          return ValidationException(message ?? 'Validation error');
        } else if (statusCode == 404) {
          return ServerException(message ?? 'Resource not found');
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(message ?? 'Server error occurred');
        }
        return ServerException(message ?? 'Unknown error occurred');

      case DioExceptionType.cancel:
        return NetworkException('Request cancelled');

      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
          return NetworkException('No internet connection');
        }
        return NetworkException('Connection error. Please check your internet connection.');

      case DioExceptionType.badCertificate:
        return NetworkException('SSL certificate error');

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException('No internet connection');
        }
        return NetworkException('Unknown error occurred');
    }
  }

  // ==================== Utility Methods ====================

  /// Get Dio instance untuk custom configuration
  Dio get dio => _dio;

  /// Update base URL
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Add custom header
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Remove custom header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Clear all custom headers
  void clearHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
  }
}
