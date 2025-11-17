import '../models/user.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.authLogin,
        data: {
          'email': email,
          'password': password,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Login failed');
      }

      final authResponse = AuthResponse.fromJson(response.data!);

      // Save tokens and user data
      await _storage.saveTokens(authResponse.tokens);
      await _storage.saveUser(authResponse.user);

      return authResponse;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Register
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String role = AppConstants.rolePlayer,
  }) async {
    try {
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

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Registration failed');
      }

      final authResponse = AuthResponse.fromJson(response.data!);

      // Save tokens and user data
      await _storage.saveTokens(authResponse.tokens);
      await _storage.saveUser(authResponse.user);

      return authResponse;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(AppConstants.authLogout);
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout API call failed: $e');
    } finally {
      // Clear local storage
      await _storage.clearAll();
    }
  }

  // Refresh Token
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
        final tokens = AuthTokens.fromJson(response.data!['tokens']);
        await _storage.saveTokens(tokens);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Get Current User
  User? getCurrentUser() {
    return _storage.getUser();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _storage.hasAccessToken() && getCurrentUser() != null;
  }

  // Get Access Token
  String? getAccessToken() {
    return _storage.getAccessToken();
  }

  // Update User (after profile edit)
  Future<void> updateLocalUser(User user) async {
    await _storage.saveUser(user);
  }
}