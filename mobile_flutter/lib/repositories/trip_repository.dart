import '../mock/mock_data.dart';
import '../models/app_models.dart';

abstract class TripRepository {
  Future<List<Trip>> getTrips();
  Future<Trip?> getTripById(String id);
  Future<Trip> addTrip(Trip trip);
  Future<Trip> updateTrip(Trip trip);
  Future<void> deleteTrip(String tripId);
}

class MockTripRepository implements TripRepository {
  final List<Trip> _trips = List<Trip>.from(MockData.trips);

  @override
  Future<List<Trip>> getTrips() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List<Trip>.from(_trips);
  }

  @override
  Future<Trip?> getTripById(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _trips.where((trip) => trip.id == id).firstOrNull;
  }

  @override
  Future<Trip> addTrip(Trip trip) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _trips.add(trip);
    return trip;
  }

  @override
  Future<Trip> updateTrip(Trip trip) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _trips.indexWhere((item) => item.id == trip.id);
    if (index >= 0) {
      _trips[index] = trip;
    } else {
      _trips.add(trip);
    }
    return trip;
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _trips.removeWhere((trip) => trip.id == tripId);
  }
}

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
