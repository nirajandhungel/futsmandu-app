import '../models/booking.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _apiService = ApiService();

  // Create Booking
  Future<Booking> createBooking(CreateBookingRequest request) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/bookings',
        data: request.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to create booking');
      }

      return Booking.fromJson(response.data!);
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

      final response = await _apiService.get<List<dynamic>>(
        '/bookings/my-bookings',
        queryParameters: queryParams,
        fromJson: (json) => json as List<dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!
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
        '/bookings/$bookingId',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to get booking details');
      }

      return Booking.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to get booking details: ${e.toString()}');
    }
  }

  // Cancel Booking
  Future<Booking> cancelBooking(String bookingId) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/bookings/$bookingId/cancel',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to cancel booking');
      }

      return Booking.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to cancel booking: ${e.toString()}');
    }
  }

  // Confirm Booking (for owners)
  Future<Booking> confirmBooking(String bookingId) async {
    try {
      final response = await _apiService.patch<Map<String, dynamic>>(
        '/bookings/$bookingId/confirm',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Failed to confirm booking');
      }

      return Booking.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to confirm booking: ${e.toString()}');
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

      final response = await _apiService.get<List<dynamic>>(
        '/bookings/owner/bookings',
        queryParameters: queryParams,
        fromJson: (json) => json as List<dynamic>,
      );

      if (!response.success || response.data == null) {
        return [];
      }

      return response.data!
          .map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get owner bookings: ${e.toString()}');
    }
  }
}