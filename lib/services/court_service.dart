import '../models/futsal_court.dart';
import '../models/court.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class CourtService {
  final ApiService _apiService = ApiService();

  // Search Futsal Courts
  Future<List<FutsalCourt>> searchFutsalCourts({
    String? city,
    String? name,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (city != null && city.isNotEmpty) {
        queryParams['city'] = city;
      }
      if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }

      final response = await _apiService.get<List<dynamic>>(
        AppConstants.courtsSearch,
        queryParameters: queryParams,
        fromJson: (json) => json as List<dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!
          .map((item) => FutsalCourt.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search courts: ${e.toString()}');
    }
  }

  // Get Futsal Court Details
  Future<FutsalCourt> getFutsalCourtDetails(String futsalCourtId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.futsalCourtsDetail}/$futsalCourtId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get court details');
      }

      return FutsalCourt.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to get court details: ${e.toString()}');
    }
  }

  // Get Court Details
  Future<Court> getCourtDetails(String courtId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.courtsDetail}/$courtId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get court details');
      }

      return Court.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to get court details: ${e.toString()}');
    }
  }

  // Get Court Availability
  Future<CourtAvailability> getCourtAvailability({
    required String courtId,
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.courtsDetail}/$courtId/availability',
        queryParameters: {'date': dateStr},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get availability');
      }

      return CourtAvailability.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to get availability: ${e.toString()}');
    }
  }

  // Get Owner's Courts (requires OWNER role)
  Future<List<FutsalCourt>> getOwnerCourts() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        AppConstants.ownerCourts,
        fromJson: (json) => json as List<dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!
          .map((item) => FutsalCourt.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get owner courts: ${e.toString()}');
    }
  }

  // Create Court (requires OWNER role)
  Future<Court> createCourt({
    required String futsalCourtId,
    required String name,
    required String courtNumber,
    required String size,
    required double hourlyRate,
    required int maxPlayers,
    String? description,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/courts/futsal-courts/$futsalCourtId/courts',
        data: {
          'name': name,
          'courtNumber': courtNumber,
          'size': size,
          'hourlyRate': hourlyRate,
          'maxPlayers': maxPlayers,
          'description': description,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to create court');
      }

      return Court.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to create court: ${e.toString()}');
    }
  }

  // Get all courts for a futsal court
  Future<List<Court>> getFutsalCourtCourts(String futsalCourtId) async {
    try {
      final futsalCourt = await getFutsalCourtDetails(futsalCourtId);
      return futsalCourt.courts ?? [];
    } catch (e) {
      throw Exception('Failed to get courts: ${e.toString()}');
    }
  }
}