import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../repositories/trip_repository.dart';

class TripProvider extends ChangeNotifier {
  final TripRepository _repository;

  TripProvider({TripRepository? repository})
      : _repository = repository ?? TripRepository();

  List<TripModel> _allTrips = [];
  TripModel? _selectedTrip;
  List<ItineraryModel> _itineraries = [];
  bool _isLoading = false;
  String? _error;

  List<TripModel> get allTrips => _allTrips;
  List<TripModel> get plannedTrips => _byStatus('planned');
  List<TripModel> get ongoingTrips => _byStatus('ongoing');
  List<TripModel> get completedTrips => _byStatus('completed');
  TripModel? get selectedTrip => _selectedTrip;
  List<ItineraryModel> get itineraries => _itineraries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TripModel> _byStatus(String status) =>
      _allTrips.where((trip) => trip.status == status).toList();

  Future<void> loadTrips() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allTrips = await _repository.getAllTrips();
    } catch (e) {
      _error = _message(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTripDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedTrip = await _repository.getTripById(id);
      _itineraries = await _repository.getItineraries(id);
    } catch (e) {
      _error = _message(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTrip(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final trip = await _repository.createTrip(data);
      _allTrips = [trip, ..._allTrips];
      _selectedTrip = trip;
    } catch (e) {
      _error = _message(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTrip(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final trip = await _repository.updateTrip(id, data);
      _allTrips = _allTrips.map((item) => item.id == id ? trip : item).toList();
      if (_selectedTrip?.id == id) {
        _selectedTrip = trip;
      }
    } catch (e) {
      _error = _message(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTrip(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteTrip(id);
      _allTrips = _allTrips.where((trip) => trip.id != id).toList();
      if (_selectedTrip?.id == id) {
        _selectedTrip = null;
        _itineraries = [];
      }
    } catch (e) {
      _error = _message(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadItineraries(int tripId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _itineraries = await _repository.getItineraries(tripId);
    } catch (e) {
      _error = _message(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTrip(TripModel trip) {
    _selectedTrip = trip;
    notifyListeners();
  }

  String _message(Object e) => e.toString().replaceFirst('Exception: ', '');
}
