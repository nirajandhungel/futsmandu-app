import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/api_response.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  final StorageService _storage = StorageService();

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token if available
          final token = _storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('📤 REQUEST[${options.method}] => PATH: ${options.path}');
          print('📤 Headers: ${options.headers}');
          print('📤 Data: ${options.data}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('📥 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          print('📥 Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          print('❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          print('❌ Message: ${error.message}');
          print('❌ Data: ${error.response?.data}');

          // Handle 401 Unauthorized - Token expired
          if (error.response?.statusCode == 401) {
            // Attempt token refresh
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request
              return handler.resolve(await _retry(error.requestOptions));
            } else {
              // Refresh failed, clear tokens and reject
              await _storage.clearAll();
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        AppConstants.authRefreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success']) {
        final tokens = response.data['data']['tokens'];
        await _storage.saveAccessToken(tokens['accessToken']);
        await _storage.saveRefreshToken(tokens['refreshToken']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PATCH request
  Future<ApiResponse<T>> patch<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        T Function(dynamic)? fromJson,
      }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiError _handleError(DioException error) {
    if (error.response?.data != null) {
      return ApiError.fromJson(error.response!.data);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          message: 'Connection timeout. Please check your internet connection.',
          code: 'TIMEOUT',
        );
      case DioExceptionType.badResponse:
        return ApiError(
          message: 'Server error. Please try again later.',
          code: 'SERVER_ERROR',
        );
      case DioExceptionType.cancel:
        return ApiError(
          message: 'Request cancelled',
          code: 'CANCELLED',
        );
      default:
        return ApiError(
          message: 'Network error. Please check your connection.',
          code: 'NETWORK_ERROR',
        );
    }
  }

  Dio get dio => _dio;
}