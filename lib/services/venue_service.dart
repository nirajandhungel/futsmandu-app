import '../models/venue.dart';
import '../models/court.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class VenueService {
  final ApiService _apiService = ApiService();

  // Search Venues
  Future<List<Venue>> searchVenues({
    String? city,
    String? name,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiService.get(
      AppConstants.venuesSearch,
      queryParameters: {
        "city": city,
        "name": name,
        "page": page.toString(),
        "limit": limit.toString(),
      },
    );

    return (response.data['venues'] as List)
        .map((v) => Venue.fromJson(v))
        .toList();
  }

  //  get all Venues
  Future<List<Venue>> getVenues({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiService.get(
      AppConstants.venuesDetail,
    );

    return (response.data['venues'] as List)
        .map((v) => Venue.fromJson(v))
        .toList();
  }

  // Get Venue Details
  Future<Venue> getVenueDetails(String venueId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.venuesDetail}/$venueId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get court details');
      }

      // Server returns: { venue: {...} }
      final data = response.data as Map<String, dynamic>;
      final venue = data['venue'] as Map<String, dynamic>?;
      
      if (venue == null) {
        throw Exception('Venue data not found in response');
      }

      return Venue.fromJson(venue);
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

  // Get Owner's Venues (requires OWNER role)
  Future<List<Venue>> getOwnerVenues() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.ownerVenues,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      // Server returns: { venues: [...], courts: [...] } or similar structure
      final data = response.data as Map<String, dynamic>;
      final venuesList = data['venues'] as List<dynamic>?;
      
      if (venuesList == null) {
        return [];
      }

      return venuesList
          .map((item) => Venue.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get owner courts: ${e.toString()}');
    }
  }

  // Create Court (requires OWNER role)
  Future<Court> createCourt({
    required String venueId,
    required String name,
    required String courtNumber,
    required String size,
    required double hourlyRate,
    required int maxPlayers,
    String? description,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${AppConstants.venuesDetail}/$venueId/courts',
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

  // Get all courts for a venue
  Future<List<Court>> getVenueCourts(String venueId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.venuesDetail}/$venueId/courts',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get courts');
      }

      // Server returns: { venue: {...}, courts: [...] }
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