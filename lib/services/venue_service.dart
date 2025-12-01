import '../models/venue.dart';
import '../models/court.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class VenueService {
  final ApiService _apiService = ApiService();

  // Helper method to transform API response to match Venue model
  Map<String, dynamic> _transformVenueJson(Map<String, dynamic> json) {
    // Extract nested location data
    final location = json['location'] ?? {};
    final coordinates = location['coordinates'] ?? {};
    final contact = json['contact'] ?? {};

    // Fix double-nested amenities
    List<String>? amenities;
    if (json['amenities'] != null) {
      try {
        final rawAmenities = json['amenities'];

        if (rawAmenities is List && rawAmenities.isNotEmpty) {
          // Check if first element is also a list (double-nested)
          if (rawAmenities[0] is List) {
            // Double-nested: [["Parking", "WiFi"]] -> ["Parking", "WiFi"]
            amenities = (rawAmenities[0] as List)
                .map((item) => item.toString())
                .toList();
            print('🔧 Fixed double-nested amenities: $amenities');
          } else {
            // Already flat: ["Parking", "WiFi"]
            amenities = rawAmenities
                .map((item) => item.toString())
                .toList();
          }
        }
      } catch (e) {
        print('⚠️ Error parsing amenities: $e');
        amenities = null;
      }
    }

    return {
      'id': json['id'] ?? json['_id'] ?? '',
      'name': json['name'] ?? '',
      'address': location['address'] ?? '',
      'city': location['city'] ?? '',
      'description': json['description'],
      'phoneNumber': contact['phone'],
      'email': contact['email'],
      'latitude': coordinates['latitude']?.toDouble(),
      'longitude': coordinates['longitude']?.toDouble(),
      'rating': json['rating']?.toDouble(),
      'totalReviews': json['totalReviews'],
      'isActive': json['isActive'] ?? true,
      'ownerId': json['ownerId'] ?? '',
      'amenities': amenities,
      'images': json['images'] != null ? List<String>.from(json['images']) : null,
      'courts': json['courts'],
      'createdAt': json['createdAt'],
    };
  }

  // Search Venues
  Future<List<Venue>> searchVenues({
    String? city,
    String? name,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        AppConstants.venuesSearch,
        queryParameters: {
          "city": city,
          "name": name,
          "page": page.toString(),
          "limit": limit.toString(),
        },
      );

      print('📥 Search Response: ${response.data}');

      // Handle nested data structure
      final data = response.data;
      List<dynamic> venuesList;

      if (data is Map) {
        // Check if venues are nested inside 'data'
        if (data.containsKey('data') && data['data'] is Map) {
          venuesList = (data['data']['venues'] as List?) ?? [];
        } else if (data.containsKey('venues')) {
          venuesList = (data['venues'] as List?) ?? [];
        } else {
          venuesList = [];
        }
      } else {
        venuesList = [];
      }

      print('📊 Found ${venuesList.length} venues');

      return venuesList.map((v) {
        final transformedJson = _transformVenueJson(v as Map<String, dynamic>);
        return Venue.fromJson(transformedJson);
      }).toList();
    } catch (e) {
      print('❌ Error in searchVenues: $e');
      throw Exception('Failed to search venues: $e');
    }
  }

  // Get all Venues
  Future<List<Venue>> getVenues({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        AppConstants.venuesDetail,
      );

      print('📥 Get Venues Response: ${response.data}');

      // Handle nested data structure
      final data = response.data;
      List<dynamic> venuesList;

      if (data is Map) {
        // Check if venues are nested inside 'data'
        if (data.containsKey('data') && data['data'] is Map) {
          venuesList = (data['data']['venues'] as List?) ?? [];
        } else if (data.containsKey('venues')) {
          venuesList = (data['venues'] as List?) ?? [];
        } else {
          venuesList = [];
        }
      } else {
        venuesList = [];
      }

      print('📊 Found ${venuesList.length} venues');

      return venuesList.map((v) {
        final transformedJson = _transformVenueJson(v as Map<String, dynamic>);
        print('🔄 Transformed: ${transformedJson['name']}');
        return Venue.fromJson(transformedJson);
      }).toList();
    } catch (e) {
      print('❌ Error in getVenues: $e');
      throw Exception('Failed to get venues: $e');
    }
  }

  // Get Venue Details
  Future<Venue> getVenueDetails(String venueId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.venuesDetail}/$venueId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get venue details');
      }

      // Server returns: { venue: {...} } or { data: { venue: {...} } }
      final data = response.data as Map<String, dynamic>;
      Map<String, dynamic>? venueJson;

      if (data.containsKey('data') && data['data'] is Map) {
        venueJson = data['data']['venue'] as Map<String, dynamic>?;
      } else if (data.containsKey('venue')) {
        venueJson = data['venue'] as Map<String, dynamic>?;
      }

      if (venueJson == null) {
        throw Exception('Venue data not found in response');
      }

      final transformedJson = _transformVenueJson(venueJson);
      return Venue.fromJson(transformedJson);
    } catch (e) {
      throw Exception('Failed to get venue details: ${e.toString()}');
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
      List<dynamic> venuesList;

      if (data.containsKey('data') && data['data'] is Map) {
        venuesList = (data['data']['venues'] as List?) ?? [];
      } else if (data.containsKey('venues')) {
        venuesList = (data['venues'] as List?) ?? [];
      } else {
        venuesList = [];
      }

      return venuesList.map((item) {
        final transformedJson = _transformVenueJson(item as Map<String, dynamic>);
        return Venue.fromJson(transformedJson);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get owner venues: ${e.toString()}');
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
