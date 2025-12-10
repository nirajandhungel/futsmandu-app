import 'package:dio/dio.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../models/api_response.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  // Simple method to extract error message
  String _getErrorMessage(dynamic error, ApiResponse? response) {
    try {
    if (response == null) {
      return 'No response from server';
    }
    
    print('🔍 Getting error message from response:');
    print('🔍 Response success: ${response.success}');
    print('🔍 Response error: ${response.error}');
    print('🔍 Response message: ${response.message}');
    
    // 1. First check ApiResponse.error
    if (response.error != null) {
      print('🔍 Using ApiError: ${response.error!.formattedMessage}');
      return response.error!.formattedMessage;
    }
    
    // 2. Check ApiResponse.message
    if (response.message != null && response.message!.isNotEmpty) {
      print('🔍 Using response message: ${response.message}');
      return response.message!;
    }
    
    // 3. Fallback
    print('🔍 Using fallback message');
    return response.success ? 'Success' : 'An error occurred';
  } catch (e) {
    print('❌ Error in _getErrorMessage: $e');
    return 'An error occurred. Please try again.';
  }
}

Future<AuthResponse> login({
  required String email,
  required String password,
}) async {
  final response = await _apiService.post<Map<String, dynamic>>(
    AppConstants.authLogin,
    data: {'email': email, 'password': password},
    fromJson: (json) => json as Map<String, dynamic>,
  );

  if (!response.success) {
    // Debug: Print the raw response to see structure
    print('🔴 Raw API Response:');
    print(response.data);
    
    // DIRECT ACCESS to error data - just like React!
    final data = response.data as Map<String, dynamic>?;
    if (data != null && data.containsKey('error')) {
      final error = data['error'] as Map<String, dynamic>;
      final message = error['message']?.toString() ?? 'Login failed';
      final details = error['details'] as Map<String, dynamic>?;
      final suggestion = details?['suggestion']?.toString();
      
      // Store both message and suggestion separately
      throw {
        'message': message,
        'suggestion': suggestion,
        'code': error['code']?.toString(),
        'rawError': error, // Keep raw error for debugging
      };
    }
    
    // Fallback
    throw {'message': response.message ?? 'Login failed'};
  }

  final authResponse = AuthResponse.fromJson(response.data!);
  await _storage.saveTokens(authResponse.tokens);
  await _storage.saveUser(authResponse.user);
  return authResponse;
}

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String role = AppConstants.rolePlayer,
  }) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      AppConstants.authRegister,
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'role': role,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (!response.success) {
      throw Exception(_getErrorMessage(null, response));
    }

    final authResponse = AuthResponse.fromJson(response.data!);
    await _storage.saveTokens(authResponse.tokens);
    await _storage.saveUser(authResponse.user);
    return authResponse;
  }

  // Rest of the methods remain the same...
  Future<void> logout() async {
    try {
      await _apiService.post(AppConstants.authLogout);
    } catch (e) {
      print('Logout API call failed: $e');
    } finally {
      await _storage.clearAll();
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.authRefreshToken,
        data: {'refreshToken': refreshToken},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final tokens = AuthTokens.fromJson(data);
        await _storage.saveTokens(tokens);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  User? getCurrentUser() {
    return _storage.getUser();
  }

  bool isLoggedIn() {
    return _storage.hasAccessToken() && getCurrentUser() != null;
  }

  String? getAccessToken() {
    return _storage.getAccessToken();
  }

  Future<void> updateLocalUser(User user) async {
    await _storage.saveUser(user);
  }
}