import '../models/booking.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _apiService = ApiService();

  // Create Booking
  Future<Booking> createBooking(CreateBookingRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.bookings,
        data: request.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to create booking');
      }

      // Server returns: { booking: {...} }
      final data = response.data as Map<String, dynamic>;
      final booking = data['booking'] as Map<String, dynamic>?;
      
      if (booking == null) {
        throw Exception('Booking data not found in response');
      }

      return Booking.fromJson(booking);
    } catch (e) {
      throw Exception('Failed to create booking: ${e.toString()}');
    }
  }

  // Get User's Bookings
  Future<List<Booking>> getUserBookings({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (status != null) {
        queryParams['status'] = status;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.myBookings,
        queryParameters: queryParams,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      // Server returns: { bookings: [...], count: ... }
      final data = response.data as Map<String, dynamic>;
      final bookingsList = data['bookings'] as List<dynamic>?;
      
      if (bookingsList == null) {
        return [];
      }

      return bookingsList
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get bookings: ${e.toString()}');
    }
  }

  // Get Booking Details
  Future<Booking> getBookingDetails(String bookingId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.bookings}/$bookingId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get booking details');
      }

      // Server returns: { booking: {...} }
      final data = response.data as Map<String, dynamic>;
      final booking = data['booking'] as Map<String, dynamic>?;
      
      if (booking == null) {
        throw Exception('Booking data not found in response');
      }

      return Booking.fromJson(booking);
    } catch (e) {
      throw Exception('Failed to get booking details: ${e.toString()}');
    }
  }
  
  // Get Joinable Bookings (Public)
  Future<List<Booking>> getJoinableBookings() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.bookingsJoinable, // endpoints already added
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      // Server returns: { groups: [...], count: ... }  <-- Updated based on actual API response
      final data = response.data as Map<String, dynamic>;
      // The API returns "groups" for joinable bookings
      final bookingsList = (data['groups'] ?? data['bookings']) as List<dynamic>?;
      
      if (bookingsList == null) {
        return [];
      }

      return bookingsList
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get joinable bookings: ${e.toString()}');
    }
  }

  // Join a booking
  Future<Booking> joinBooking(String bookingId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.bookingJoin.replaceFirst('id', bookingId),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to join booking');
      }

      // Server returns: { booking: {...}, autoConfirmed: ... }
      final data = response.data as Map<String, dynamic>;
      final booking = data['booking'] as Map<String, dynamic>?;
      
      if (booking == null) {
        throw Exception('Booking data not found in response');
      }

      return Booking.fromJson(booking);
    } catch (e) {
      throw Exception('Failed to join booking: ${e.toString()}');
    }
  }

  // Leave a booking
  Future<Booking> leaveBooking(String bookingId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.bookingLeave.replaceFirst('id', bookingId),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to leave booking');
      }

      // Server returns: { booking: {...} }
      final data = response.data as Map<String, dynamic>;
      final booking = data['booking'] as Map<String, dynamic>?;
      
      if (booking == null) {
        throw Exception('Booking data not found in response');
      }

      return Booking.fromJson(booking);
    } catch (e) {
      throw Exception('Failed to leave booking: ${e.toString()}');
    }
  }

  // Invite players to a booking
  Future<Booking> invitePlayers(String bookingId, List<String> userIds) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${AppConstants.bookingInvite}/$bookingId',
        data: {'userIds': userIds},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to invite players');
      }

      // Server returns: { booking: {...} }
      final data = response.data as Map<String, dynamic>;
      final booking = data['booking'] as Map<String, dynamic>?;
      
      if (booking == null) {
        throw Exception('Booking data not found in response');
      }

      return Booking.fromJson(booking);
    } catch (e) {
      throw Exception('Failed to invite players: ${e.toString()}');
    }
  }

  // Cancel Booking
  Future<Booking> cancelBooking(String bookingId) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '${AppConstants.bookings}/$bookingId/cancel',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to cancel booking');
      }

      // Server returns: { booking: {...} }
      final data = response.data as Map<String, dynamic>;
      final booking = data['booking'] as Map<String, dynamic>?;
      
      if (booking == null) {
        throw Exception('Booking data not found in response');
      }

      return Booking.fromJson(booking);
    } catch (e) {
      throw Exception('Failed to cancel booking: ${e.toString()}');
    }
  }

  // Approve Booking (for owners)
  Future<Booking> approveBooking(String bookingId) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/owner/bookings/$bookingId/approve',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to approve booking');
      }

      // Server returns: { booking: {...} }
      final data = response.data as Map<String, dynamic>;
      final booking = data['booking'] as Map<String, dynamic>?;
      
      if (booking == null) {
        throw Exception('Booking data not found in response');
      }

      return Booking.fromJson(booking);
    } catch (e) {
      throw Exception('Failed to approve booking: ${e.toString()}');
    }
  }

  // Reject Booking (for owners)
  Future<Booking> rejectBooking(String bookingId, {String? reason}) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/owner/bookings/$bookingId/reject',
        data: reason != null ? {'reason': reason} : null,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to reject booking');
      }

      // Server returns: { booking: {...} }
      final data = response.data as Map<String, dynamic>;
      final booking = data['booking'] as Map<String, dynamic>?;
      
      if (booking == null) {
        throw Exception('Booking data not found in response');
      }

      return Booking.fromJson(booking);
    } catch (e) {
      throw Exception('Failed to reject booking: ${e.toString()}');
    }
  }

  // Get Owner's Bookings (requires OWNER role)
  Future<List<Booking>> getOwnerBookings({
    String? status,
    String? futsalCourtId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (status != null) {
        queryParams['status'] = status;
      }
      if (futsalCourtId != null) {
        queryParams['futsalCourtId'] = futsalCourtId;
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        '/owner/myVenueBookings',
        queryParameters: queryParams,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      // DEBUG: Print the response structure
      print('DEBUG - Response data keys: ${response.data!.keys}');
      print('DEBUG - Data structure: ${response.data}');

      final data = response.data as Map<String, dynamic>;

      // Check for different possible keys
      List<dynamic>? bookingsList;

      if (data.containsKey('booking')) {
        bookingsList = data['booking'] as List<dynamic>?;
      } else if (data.containsKey('bookings')) {
        bookingsList = data['bookings'] as List<dynamic>?;
      } else if (data.isNotEmpty) {
        // Try to find any list in the data
        for (var key in data.keys) {
          if (data[key] is List<dynamic>) {
            bookingsList = data[key] as List<dynamic>?;
            break;
          }
        }
      }

      if (bookingsList == null || bookingsList.isEmpty) {
        return [];
      }

      return bookingsList
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get owner bookings: ${e.toString()}');
    }
  }
  // Confirm Booking (alias for approve)
  Future<Booking> confirmBooking(String bookingId) async {
    return approveBooking(bookingId);
  }
}