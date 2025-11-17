import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<Booking> _bookings = [];
  Booking? _selectedBooking;

  bool _isLoading = false;
  String? _errorMessage;

  List<Booking> get bookings => _bookings;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get user's pending bookings
  List<Booking> get pendingBookings =>
      _bookings.where((b) => b.isPending).toList();

  // Get user's confirmed bookings
  List<Booking> get confirmedBookings =>
      _bookings.where((b) => b.isConfirmed).toList();

  // Get user's past bookings
  List<Booking> get pastBookings =>
      _bookings.where((b) => b.isCompleted || b.isCancelled).toList();

  // Create Booking
  Future<bool> createBooking(CreateBookingRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final booking = await _bookingService.createBooking(request);
      _bookings.insert(0, booking);
      _selectedBooking = booking;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get User's Bookings
  Future<void> getUserBookings({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookings = await _bookingService.getUserBookings(
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _bookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get Booking Details
  Future<void> getBookingDetails(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedBooking = await _bookingService.getBookingDetails(bookingId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _selectedBooking = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel Booking
  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedBooking = await _bookingService.cancelBooking(bookingId);

      // Update booking in list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = updatedBooking;
      }

      if (_selectedBooking?.id == bookingId) {
        _selectedBooking = updatedBooking;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Confirm Booking (for owners)
  Future<bool> confirmBooking(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedBooking = await _bookingService.confirmBooking(bookingId);

      // Update booking in list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = updatedBooking;
      }

      if (_selectedBooking?.id == bookingId) {
        _selectedBooking = updatedBooking;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get Owner's Bookings
  Future<void> getOwnerBookings({
    String? status,
    String? futsalCourtId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookings = await _bookingService.getOwnerBookings(
        status: status,
        futsalCourtId: futsalCourtId,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _bookings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select Booking
  void selectBooking(Booking booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  // Clear Selection
  void clearSelection() {
    _selectedBooking = null;
    notifyListeners();
  }

  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh Bookings
  Future<void> refreshBookings() async {
    await getUserBookings();
  }
}