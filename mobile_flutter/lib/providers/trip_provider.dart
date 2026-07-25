import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../repositories/trip_repository.dart';

class TripProvider extends ChangeNotifier {
  final TripRepository _repository;

  TripProvider(this._repository);

  bool _isLoading = false;
  List<Trip> _trips = [];
  Trip? _selectedTrip;

  bool get isLoading => _isLoading;
  List<Trip> get trips => _trips;
  Trip? get selectedTrip => _selectedTrip;

  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();
    _trips = await _repository.getTrips();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectTrip(String tripId) async {
    _selectedTrip = await _repository.getTripById(tripId);
    notifyListeners();
  }

  Future<void> addTrip(Trip trip) async {
    final createdTrip = await _repository.addTrip(trip);
    _trips = [..._trips, createdTrip];
    _selectedTrip = createdTrip;
    notifyListeners();
  }

  Future<void> updateTrip(Trip trip) async {
    final updatedTrip = await _repository.updateTrip(trip);
    _trips = _trips.map((item) => item.id == updatedTrip.id ? updatedTrip : item).toList();
    _selectedTrip = updatedTrip;
    notifyListeners();
  }

  Future<void> deleteTrip(String tripId) async {
    await _repository.deleteTrip(tripId);
    _trips = _trips.where((trip) => trip.id != tripId).toList();
    if (_selectedTrip?.id == tripId) {
      _selectedTrip = null;
    }
    notifyListeners();
  }
}
