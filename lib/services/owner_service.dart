import '../models/futsal_court.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class OwnerService {
  final ApiService _apiService = ApiService();

  // Activate Owner Mode
  Future<Map<String, dynamic>> activateOwnerMode({
    required String panNumber,
    required String address,
    Map<String, dynamic>? additionalKyc,
    List<String>? documentPaths,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.ownerActivate,
        data: {
          'panNumber': panNumber,
          'address': address,
          if (additionalKyc != null) 'additionalKyc': additionalKyc,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to activate owner mode');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to activate owner mode: ${e.toString()}');
    }
  }

  // Deactivate Owner Mode
  Future<Map<String, dynamic>> deactivateOwnerMode() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.ownerDeactivate,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to deactivate owner mode');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to deactivate owner mode: ${e.toString()}');
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

  // Create Futsal Court
  Future<FutsalCourt> createFutsalCourt({
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
        AppConstants.ownerCourtsCreate,
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
        throw Exception(response.message ?? 'Failed to create futsal court');
      }

      // Server returns: { futsalCourt: {...} }
      final data = response.data as Map<String, dynamic>;
      final futsalCourt = data['futsalCourt'] as Map<String, dynamic>?;
      
      if (futsalCourt == null) {
        throw Exception('Futsal court data not found in response');
      }

      return FutsalCourt.fromJson(futsalCourt);
    } catch (e) {
      throw Exception('Failed to create futsal court: ${e.toString()}');
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

