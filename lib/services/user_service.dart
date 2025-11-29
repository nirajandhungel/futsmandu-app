import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // Get Current User Profile
  Future<User> getMyProfile() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.userProfile,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get profile');
      }

      // Server returns: { user: {...} }
      final data = response.data as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>?;
      
      if (user == null) {
        throw Exception('User data not found in response');
      }

      return User.fromJson(user);
    } catch (e) {
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  // Update User Profile
  Future<User> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['fullName'] = fullName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;

      final response = await _apiService.patch<Map<String, dynamic>>(
        AppConstants.userUpdate,
        data: updateData,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to update profile');
      }

      // Server returns: { user: {...} }
      final data = response.data as Map<String, dynamic>;
      final user = data['user'] as Map<String, dynamic>?;
      
      if (user == null) {
        throw Exception('User data not found in response');
      }

      return User.fromJson(user);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.userChangePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }
}

