import '../models/futsal_court.dart';
import '../models/court.dart';
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

      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.courtsSearchFutsal,
        queryParameters: queryParams,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      // Server returns: { futsalCourts: [...], count: ... }
      final data = response.data as Map<String, dynamic>;
      final futsalCourtsList = data['futsalCourts'] as List<dynamic>?;
      
      if (futsalCourtsList == null) {
        return [];
      }

      return futsalCourtsList
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

      // Server returns: { futsalCourt: {...} }
      final data = response.data as Map<String, dynamic>;
      final futsalCourt = data['futsalCourt'] as Map<String, dynamic>?;
      
      if (futsalCourt == null) {
        throw Exception('Futsal court data not found in response');
      }

      return FutsalCourt.fromJson(futsalCourt);
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

      // Server returns: { court: {...} }
      final data = response.data as Map<String, dynamic>;
      final court = data['court'] as Map<String, dynamic>?;
      
      if (court == null) {
        throw Exception('Court data not found in response');
      }

      return Court.fromJson(court);
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

      // Server returns availability data directly in data field
      final data = response.data as Map<String, dynamic>;
      return CourtAvailability.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get availability: ${e.toString()}');
    }
  }

  // Get Owner's Courts (requires OWNER role)
  Future<List<FutsalCourt>> getOwnerCourts() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.ownerCourts,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      // Server returns: { futsalCourts: [...], courts: [...] } or similar structure
      final data = response.data as Map<String, dynamic>;
      final futsalCourtsList = data['futsalCourts'] as List<dynamic>?;
      
      if (futsalCourtsList == null) {
        return [];
      }

      return futsalCourtsList
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
        '${AppConstants.futsalCourtsDetail}/$futsalCourtId/courts',
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

      // Server returns: { court: {...} }
      final data = response.data as Map<String, dynamic>;
      final court = data['court'] as Map<String, dynamic>?;
      
      if (court == null) {
        throw Exception('Court data not found in response');
      }

      return Court.fromJson(court);
    } catch (e) {
      throw Exception('Failed to create court: ${e.toString()}');
    }
  }

  // Get all courts for a futsal court
  Future<List<Court>> getFutsalCourtCourts(String futsalCourtId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.futsalCourtsDetail}/$futsalCourtId/courts',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get courts');
      }

      // Server returns: { futsalCourt: {...}, courts: [...] }
      final data = response.data as Map<String, dynamic>;
      final courtsList = data['courts'] as List<dynamic>?;
      
      if (courtsList == null) {
        return [];
      }

      return courtsList
          .map((item) => Court.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get courts: ${e.toString()}');
    }
  }
}