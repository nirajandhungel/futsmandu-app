import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  String? _errorSuggestion; // New field for error suggestion

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get errorSuggestion => _errorSuggestion; // Getter for suggestion
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Helper method to get formatted error message with suggestion
  String? get formattedErrorMessage {
    if (_errorMessage == null) return null;
    
    if (_errorSuggestion != null && _errorSuggestion!.isNotEmpty) {
      return '$_errorMessage\n\n$_errorSuggestion';
    }
    return _errorMessage;
  }

  // Initialize - Check if user is logged in
  Future<void> initialize() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      if (_authService.isLoggedIn()) {
        _user = _authService.getCurrentUser();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Session expired. Please login again.';
      _errorSuggestion = null;
    }

    notifyListeners();
  }

// Update just the login method in AuthProvider:
Future<bool> login({
  required String email,
  required String password,
}) async {
  _status = AuthStatus.loading;
  _errorMessage = null;
  _errorSuggestion = null;
  notifyListeners();

  try {
    final authResponse = await _authService.login(
      email: email,
      password: password,
    );

    _user = authResponse.user;
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    _errorSuggestion = null;
    notifyListeners();
    return true;
  } catch (e) {
    _status = AuthStatus.unauthenticated;
    
    // Check if error is a Map (our structured error)
    if (e is Map<String, dynamic>) {
      _errorMessage = e['message']?.toString() ?? 'Login failed';
      _errorSuggestion = e['suggestion']?.toString();
    } else if (e is String) {
      _errorMessage = e;
    } else {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    
    notifyListeners();
    return false;
  }
}
  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    String role = 'PLAYER',
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _errorSuggestion = null;
    notifyListeners();

    try {
      final authResponse = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
      );

      _user = authResponse.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      _errorSuggestion = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      
      // Parse the error message to extract message and suggestion
      final errorString = e.toString().replaceAll('Exception: ', '');
      
      // Check if the error contains both message and suggestion separated by \n\n
      if (errorString.contains('\n\n')) {
        final parts = errorString.split('\n\n');
        _errorMessage = parts[0].trim();
        _errorSuggestion = parts.length > 1 ? parts[1].trim() : null;
      } else {
        // If no suggestion, just set the message
        _errorMessage = errorString;
        _errorSuggestion = null;
      }
      
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    // Add a small delay to ensure state is updated before navigation
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      await _authService.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      _errorSuggestion = null;
    } catch (e) {
      _errorMessage = 'Logout failed';
      _errorSuggestion = 'Please try again.';
      _status = AuthStatus.unauthenticated; // Still set to unauthenticated even on error
    }

    notifyListeners();
  }

  // Update User
  Future<void> updateUser(User user) async {
    await _authService.updateLocalUser(user);
    _user = user;
    notifyListeners();
  }

  // Clear Error
  void clearError() {
    _errorMessage = null;
    _errorSuggestion = null;
    notifyListeners();
  }

  // Set custom error (useful for form validation errors)
  void setError({required String message, String? suggestion}) {
    _errorMessage = message;
    _errorSuggestion = suggestion;
    notifyListeners();
  }
}