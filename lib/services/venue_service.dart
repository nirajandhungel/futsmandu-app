import 'dart:io';
import 'package:dio/dio.dart';
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
      if (json['amenities'] is List && json['amenities'].isNotEmpty) {
        if (json['amenities'][0] is List) {
          // Double-nested, unwrap it
          amenities = List<String>.from(json['amenities'][0]);
        } else {
          // Already flat
          amenities = List<String>.from(json['amenities']);
        }
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
      'openingHours': json['openingHours'],
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

  // Create Venue
  Future<Venue> createVenue({
    required String name,
    required String description,
    required String address,
    required String city,
    required String phoneNumber,
    String? email,
    String? website,
    double? latitude,
    double? longitude,
    required List<String> amenities,
    required Map<String, dynamic> openingHours,
    required List<Map<String, dynamic>> courts,
    required List<File> venueImages,
    required Map<int, List<File>> courtImages,
  }) async {
    try {
      final formData = FormData();

      // Venue Info
      formData.fields.add(MapEntry('name', name));
      formData.fields.add(MapEntry('description', description));
      formData.fields.add(MapEntry('location[address]', address));
      formData.fields.add(MapEntry('location[city]', city));
      // Optional defaults
      formData.fields.add(const MapEntry('location[state]', 'Bagmati')); 
      if (latitude != null) formData.fields.add(MapEntry('location[coordinates][latitude]', latitude.toString()));
      if (longitude != null) formData.fields.add(MapEntry('location[coordinates][longitude]', longitude.toString()));
      
      formData.fields.add(MapEntry('contact[phone]', phoneNumber));
      if (email != null) formData.fields.add(MapEntry('contact[email]', email));
      if (website != null) formData.fields.add(MapEntry('contact[website]', website));

      // Amenities
      for (var amenity in amenities) {
        formData.fields.add(MapEntry('amenities[]', amenity));
      }

      // Opening Hours
      openingHours.forEach((day, times) {
         if (times is Map) {
           formData.fields.add(MapEntry('openingHours[$day][open]', times['open']));
           formData.fields.add(MapEntry('openingHours[$day][close]', times['close']));
         }
      });

      // Courts
      for (int i = 0; i < courts.length; i++) {
        final court = courts[i];
        formData.fields.add(MapEntry('courts[$i][courtNumber]', (i + 1).toString()));
        formData.fields.add(MapEntry('courts[$i][name]', court['name']));
        formData.fields.add(MapEntry('courts[$i][size]', court['size']));
        formData.fields.add(MapEntry('courts[$i][hourlyRate]', court['hourlyRate'].toString()));
        
        if (court['amenities'] != null && court['amenities'] is List) {
           for (var amenity in court['amenities']) {
             formData.fields.add(MapEntry('courts[$i][amenities][]', amenity));
           }
        }
      }

      // Images
      // Venue Images
      for (var file in venueImages) {
        formData.files.add(MapEntry(
          'venueImages',
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        ));
      }

      // Court Images
      for (var entry in courtImages.entries) {
        final index = entry.key;
        final files = entry.value;
        for (var file in files) {
          formData.files.add(MapEntry(
            'courtImages[$index]',
             await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
          ));
        }
      }

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.ownerVenuesCreate,
        data: formData,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to create venue');
      }

      final data = response.data as Map<String, dynamic>;
      final venueData = data['venue'] as Map<String, dynamic>?;

      if (venueData == null) {
        throw Exception('Venue data not found in response');
      }

      final transformed = _transformVenueJson(venueData);
      return Venue.fromJson(transformed);
    } catch (e) {
      throw Exception('Failed to create venue: ${e.toString()}');
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
