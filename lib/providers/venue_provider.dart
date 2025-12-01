import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../models/court.dart';
import '../services/venue_service.dart';

class VenueProvider with ChangeNotifier {
  final VenueService _venueService = VenueService();

  List<Venue> _venues = [];
  Venue? _selectedVenue;
  Court? _selectedCourt;
  CourtAvailability? _availability;

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;

  List<Venue> get venues => _venues;
  Venue? get selectedVenue => _selectedVenue;
  Court? get selectedCourt => _selectedCourt;
  CourtAvailability? get availability => _availability;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  // Search Venues
  Future<void> searchVenues({
    String? city,
    String? name,
    int page = 1,
    int limit = 10,
  }) async {
    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _venues = await _venueService.searchVenues(
        city: city,
        name: name,
        page: page,
        limit: limit,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _venues = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }
  //  get all  Venues
  Future<void> getAllVenues({
    String? city,
    String? name,
    int page = 1,
    int limit = 10,
  }) async {
    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _venues = await _venueService.getVenues(
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _venues = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Get Venue Details
  Future<void> getVenueDetails(String venueId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedVenue = await _venueService.getVenueDetails(venueId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _selectedVenue = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get Court Details
  Future<void> getCourtDetails(String courtId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedCourt = await _venueService.getCourtDetails(courtId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _selectedCourt = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get Court Availability
  Future<void> getCourtAvailability({
    required String courtId,
    required DateTime date,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _availability = await _venueService.getCourtAvailability(
        courtId: courtId,
        date: date,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _availability = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get Owner's Venues
  Future<void> getOwnerVenues() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _venues = await _venueService.getOwnerVenues();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _venues = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Court
  Future<bool> createCourt({
    required String venueId,
    required String name,
    required String courtNumber,
    required String size,
    required double hourlyRate,
    required int maxPlayers,
    String? description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _venueService.createCourt(
        venueId: venueId,
        name: name,
        courtNumber: courtNumber,
        size: size,
        hourlyRate: hourlyRate,
        maxPlayers: maxPlayers,
        description: description,
      );
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

  // Set Selected Entities
  void selectVenue(Venue venue) {
    _selectedVenue = venue;
    notifyListeners();
  }

  void selectCourt(Court court) {
    _selectedCourt = court;
    notifyListeners();
  }

  // Clear Selection
  void clearSelection() {
    _selectedVenue = null;
    _selectedCourt = null;
    _availability = null;
    notifyListeners();
  }

  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh Courts
  Future<void> refreshVenues() async {
    await searchVenues();
  }
}