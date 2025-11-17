import 'package:flutter/material.dart';
import '../models/futsal_court.dart';
import '../models/court.dart';
import '../services/court_service.dart';

class CourtProvider with ChangeNotifier {
  final CourtService _courtService = CourtService();

  List<FutsalCourt> _courts = [];
  FutsalCourt? _selectedFutsalCourt;
  Court? _selectedCourt;
  CourtAvailability? _availability;

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;

  List<FutsalCourt> get courts => _courts;
  FutsalCourt? get selectedFutsalCourt => _selectedFutsalCourt;
  Court? get selectedCourt => _selectedCourt;
  CourtAvailability? get availability => _availability;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  // Search Futsal Courts
  Future<void> searchCourts({String? city, String? name}) async {
    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courts = await _courtService.searchFutsalCourts(
        city: city,
        name: name,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _courts = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Get Futsal Court Details
  Future<void> getFutsalCourtDetails(String futsalCourtId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedFutsalCourt = await _courtService.getFutsalCourtDetails(futsalCourtId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _selectedFutsalCourt = null;
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
      _selectedCourt = await _courtService.getCourtDetails(courtId);
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
      _availability = await _courtService.getCourtAvailability(
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

  // Get Owner's Courts
  Future<void> getOwnerCourts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courts = await _courtService.getOwnerCourts();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _courts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Court
  Future<bool> createCourt({
    required String futsalCourtId,
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
      await _courtService.createCourt(
        futsalCourtId: futsalCourtId,
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

  // Set Selected Court
  void selectFutsalCourt(FutsalCourt court) {
    _selectedFutsalCourt = court;
    notifyListeners();
  }

  void selectCourt(Court court) {
    _selectedCourt = court;
    notifyListeners();
  }

  // Clear Selection
  void clearSelection() {
    _selectedFutsalCourt = null;
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
  Future<void> refreshCourts() async {
    await searchCourts();
  }
}