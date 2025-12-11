import '../models/venue.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService = ApiService();

  // Get Dashboard Statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.adminDashboard,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get dashboard stats');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get dashboard stats: ${e.toString()}');
    }
  }

  // Get Pending Owner Requests
  Future<List<Map<String, dynamic>>> getPendingOwnerRequests({
    int? page,
    int? limit,
    String? status,
    String? search,
    String? sort,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;
      if (sort != null) queryParams['sort'] = sort;

      final response = await _apiService.get<List<dynamic>>(
        AppConstants.adminOwnersPending,
        queryParameters: queryParams,
        fromJson: (json) => json as List<dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending owner requests: ${e.toString()}');
    }
  }

  // Approve Owner Request
  Future<Map<String, dynamic>> approveOwnerRequest(
    String ownerId, {
    required String status,
    String? notes,
  }) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '${AppConstants.adminOwnersApprove}/$ownerId/approve',
        data: {
          'status': status,
          if (notes != null) 'notes': notes,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to approve owner request');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to approve owner request: ${e.toString()}');
    }
  }

  // Update Owner Status
  Future<Map<String, dynamic>> updateOwnerStatus(
    String ownerId, {
    required bool isActive,
    String? reason,
  }) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '${AppConstants.adminOwnersStatus}/$ownerId/status',
        data: {
          'isActive': isActive,
          if (reason != null) 'reason': reason,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to update owner status');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to update owner status: ${e.toString()}');
    }
  }

  // Get All Users
  Future<List<User>> getAllUsers({
    int? page,
    int? limit,
    String? role,
    bool? isActive,
    String? search,
    String? sort,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (role != null) queryParams['role'] = role;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (search != null) queryParams['search'] = search;
      if (sort != null) queryParams['sort'] = sort;

      final response = await _apiService.get<List<dynamic>>(
        AppConstants.adminUsers,
        queryParameters: queryParams,
        fromJson: (json) => json as List<dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: ${e.toString()}');
    }
  }

  // Get User By ID
  Future<User> getUserById(String userId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.adminUserById}/$userId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get user');
      }

      final data = response.data as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>?;
      
      if (user == null) {
        throw Exception('User data not found in response');
      }

      return User.fromJson(user);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  // Update User Status
 // Update User Status
Future<User> updateUserStatus(
  String userId, {
  required bool isActive,
  String? reason,
}) async {
  try {
    final response = await _apiService.patch<Map<String, dynamic>>(
      '${AppConstants.adminUserStatus}/$userId/status',
      data: {
        'isActive': isActive,
        if (reason != null) 'reason': reason,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );

    print('📥 AdminService.updateUserStatus response:');
    print('📥 Success: ${response.success}');
    print('📥 Data: ${response.data}');
    print('📥 Error: ${response.error}');
    print('📥 Message: ${response.message}');

    if (!response.success) {
      String errorMessage = 'Failed to update user status';
      
      // Check if the operation actually succeeded but API returns success: false
      final data = response.data as Map<String, dynamic>?;
      if (data != null && data.containsKey('user')) {
        print('⚠️ API returned success: false but has user data, assuming operation succeeded');
        final userData = data['user'] as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      
      if (response.error != null) {
        errorMessage = response.error!.formattedMessage;
      } else if (response.message != null) {
        errorMessage = response.message!;
      }
      
      throw Exception(errorMessage);
    }

    // Try to extract user from response
    final data = response.data as Map<String, dynamic>;
    
    // Check for user in different possible locations
    if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
      return User.fromJson(data['user'] as Map<String, dynamic>);
    }
    
    if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
      final innerData = data['data'] as Map<String, dynamic>;
      if (innerData.containsKey('user') && innerData['user'] is Map<String, dynamic>) {
        return User.fromJson(innerData['user'] as Map<String, dynamic>);
      }
      if (innerData.containsKey('id')) {
        return User.fromJson(innerData);
      }
    }
    
    if (data.containsKey('id')) {
      return User.fromJson(data);
    }

    // If we reach here, the API didn't return user data
    // Create a minimal user with updated status
    print('⚠️ No user data returned from API, creating minimal user object');
    return User.fromJson({
      'id': userId,
      'isActive': isActive,
    });
    
  } catch (e) {
    print('❌ AdminService.updateUserStatus error: $e');
    rethrow;
  }
}
  // Delete User
  Future<void> deleteUser(String userId) async {
    try {
      final response = await _apiService.delete(
        '${AppConstants.adminUserById}/$userId',
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to delete user');
      }
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  // Get All Venues
  Future<List<Venue>> getAllVenues({
    int? page,
    int? limit,
    bool? isVerified,
    bool? isActive,
    String? search,
    String? sort,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (isVerified != null) queryParams['isVerified'] = isVerified.toString();
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (search != null) queryParams['search'] = search;
      if (sort != null) queryParams['sort'] = sort;

      final response = await _apiService.get<List<dynamic>>(
        AppConstants.adminVenues,
        queryParameters: queryParams,
        fromJson: (json) => json as List<dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!
          .map((item) => Venue.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get venues: ${e.toString()}');
    }
  }

  // Verify Venue
  Future<Venue> verifyVenue(String venueId) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '${AppConstants.adminVenueVerify}/$venueId/verify',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to verify futsal court');
      }

      final data = response.data as Map<String, dynamic>;
      final venue = data['venue'] as Map<String, dynamic>?;
      
      if (venue == null) {
        throw Exception('Venue data not found in response');
      }

      return Venue.fromJson(venue);
    } catch (e) {
      throw Exception('Failed to verify venue: ${e.toString()}');
    }
  }

  // Suspend Venue
  Future<Venue> suspendVenue(String venueId) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '${AppConstants.adminVenueSuspend}/$venueId/suspend',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to suspend futsal court');
      }

      final data = response.data as Map<String, dynamic>;
      final venue = data['venue'] as Map<String, dynamic>?;
      
      if (venue == null) {
        throw Exception('Venue data not found in response');
      }

      return Venue.fromJson(venue);
    } catch (e) {
      throw Exception('Failed to suspend venue: ${e.toString()}');
    }
  }

  // Reactivate Venue
  Future<Venue> reactivateVenue(String venueId) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '${AppConstants.adminVenueReactivate}/$venueId/reactivate',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to reactivate futsal court');
      }

      final data = response.data as Map<String, dynamic>;
      final venue = data['venue'] as Map<String, dynamic>?;
      
      if (venue == null) {
        throw Exception('Venue data not found in response');
      }

      return Venue.fromJson(venue);
    } catch (e) {
      throw Exception('Failed to reactivate venue: ${e.toString()}');
    }
  }
}

