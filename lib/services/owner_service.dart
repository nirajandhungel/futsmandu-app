import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/venue.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class OwnerService {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  // Activate Owner Mode (with file uploads)
  Future<AuthResponse> activateOwnerMode({
    required String panNumber,
    required String address,
    required String phoneNumber,
    Map<String, dynamic>? additionalKyc,
    required File profilePhoto,
    required File citizenshipFront,
    required File citizenshipBack,
  }) async {
    try {
      final dio = _apiService.dio;
      final token = _storage.getAccessToken();
      
      // Create FormData for multipart/form-data
      // Convert additionalKyc to JSON string if provided
      String? additionalKycJsonString;
      if (additionalKyc != null && additionalKyc.isNotEmpty) {
        // Remove phoneNumber from additionalKyc if it exists (we're sending it separately)
        final kycData = Map<String, dynamic>.from(additionalKyc);
        kycData.remove('phoneNumber'); // phoneNumber is sent separately
        if (kycData.isNotEmpty) {
          additionalKycJsonString = jsonEncode(kycData);
        }
      }
      
      final formData = FormData.fromMap({
        'panNumber': panNumber,
        'address': address,
        'phoneNumber': phoneNumber,
        if (additionalKycJsonString != null) 'additionalKyc': additionalKycJsonString,
        'profilePhoto': await MultipartFile.fromFile(
          profilePhoto.path,
          filename: 'profile_photo.jpg',
        ),
        'citizenshipFront': await MultipartFile.fromFile(
          citizenshipFront.path,
          filename: 'citizenship_front.jpg',
        ),
        'citizenshipBack': await MultipartFile.fromFile(
          citizenshipBack.path,
          filename: 'citizenship_back.jpg',
        ),
      });

      // Make request with proper headers (Dio will set Content-Type automatically for FormData)
      final response = await dio.post(
        AppConstants.ownerActivate,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Server returns: { success: true, data: { user: {...}, tokens: {...} } }
        final data = response.data['data'] as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);
        
        // Save tokens and user data
        await _storage.saveTokens(authResponse.tokens);
        await _storage.saveUser(authResponse.user);
        
        return authResponse;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to activate owner mode');
      }
    } catch (e) {
      if (e is DioException) {
        final message = e.response?.data?['message'] ?? e.message ?? 'Failed to activate owner mode';
        throw Exception(message);
      }
      throw Exception('Failed to activate owner mode: ${e.toString()}');
    }
  }

  // // Deactivate Owner Mode
  // Future<AuthResponse> deactivateOwnerMode({String? reason}) async {
  //   try {
  //     final response = await _apiService.post<Map<String, dynamic>>(
  //       AppConstants.ownerDeactivate,
  //       data: reason != null ? {'reason': reason} : null,
  //       fromJson: (json) => json as Map<String, dynamic>,
  //     );

  //     if (!response.success || response.data == null) {
  //       throw Exception(response.message ?? 'Failed to deactivate owner mode');
  //     }

  //     // Server returns: { success: true, data: { user: {...}, tokens: {...} } }
  //     final data = response.data as Map<String, dynamic>;
  //     final authResponse = AuthResponse.fromJson(data);
      
  //     // Save tokens and user data
  //     await _storage.saveTokens(authResponse.tokens);
  //     await _storage.saveUser(authResponse.user);
      
  //     return authResponse;
  //   } catch (e) {
  //     throw Exception('Failed to deactivate owner mode: ${e.toString()}');
  //   }
  // }
  // Deactivate Owner Mode
  Future<AuthResponse> activatePlayerMode({String? reason}) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.playerActivate,
        data: reason != null ? {'reason': reason} : null,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to activate player mode');
      }

      // Server returns: { success: true, data: { user: {...}, tokens: {...} } }
      final data = response.data as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);
      
      // Save tokens and user data
      await _storage.saveTokens(authResponse.tokens);
      await _storage.saveUser(authResponse.user);
      
      return authResponse;
    } catch (e) {
      throw Exception('Failed to activate player mode: ${e.toString()}');
    }
  }

  // Switch to Owner Mode (for already approved owners)
  Future<AuthResponse> switchToOwnerMode() async {
    try {
      // Using ownerActivate endpoint but without KYC files since user is already approved
      // The backend should handle this as a mode switch if the user is already APPROVED
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.ownerMode, // Updated to use inferred endpoint
        data: {}, // Empty body for mode switch
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to switch to owner mode');
      }

      final data = response.data as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);
      
      await _storage.saveTokens(authResponse.tokens);
      await _storage.saveUser(authResponse.user);
      
      return authResponse;
    } catch (e) {
       if (e is DioException) {
        final message = e.response?.data?['message'] ?? e.message ?? 'Failed to switch to owner mode';
        throw Exception(message);
      }
      throw Exception('Failed to switch to owner mode: ${e.toString()}');
    }
  }

  // Get Owner Profile
  Future<Map<String, dynamic>> getOwnerProfile() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.ownerProfile,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get owner profile');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get owner profile: ${e.toString()}');
    }
  }

  // Create Venue
  Future<Venue> createVenue({
    required String name,
    required String address,
    required String city,
    String? description,
    String? phoneNumber,
    String? email,
    double? latitude,
    double? longitude,
    List<String>? amenities,
    List<String>? imagePaths,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.ownerVenuesCreate,
        data: {
          'name': name,
          'address': address,
          'city': city,
          if (description != null) 'description': description,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (email != null) 'email': email,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (amenities != null) 'amenities': amenities,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to create venue');
      }

      // Server returns: { venue: {...} }
      final data = response.data as Map<String, dynamic>;
      final venue = data['venue'] as Map<String, dynamic>?;
      
      if (venue == null) {
        throw Exception('Venue data not found in response');
      }

      return Venue.fromJson(venue);
    } catch (e) {
      throw Exception('Failed to create venue: ${e.toString()}');
    }
  }

  // Get Owner Dashboard Analytics
  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.ownerDashboard,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get dashboard analytics');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get dashboard analytics: ${e.toString()}');
    }
  }
}

