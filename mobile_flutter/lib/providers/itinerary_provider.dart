import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../repositories/trip_repository.dart';

class ItineraryProvider extends ChangeNotifier {
  final TripRepository _repository;

  ItineraryProvider({TripRepository? repository})
      : _repository = repository ?? TripRepository();

  List<ItineraryItemModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<ItineraryItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadItems(int itineraryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.getItineraryItems(itineraryId);
    } catch (e) {
      _error = _message(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createItem(int itineraryId, Map<String, dynamic> data) async {
    _error = null;

    try {
      await _repository.createItineraryItem(itineraryId, data);
      _items = await _repository.getItineraryItems(itineraryId);
    } catch (e) {
      _error = _message(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateItem(int id, Map<String, dynamic> data) async {
    _error = null;

    try {
      await _repository.updateItineraryItem(id, data);
      final itineraryId = _itineraryIdFor(id);
      if (itineraryId != null) {
        _items = await _repository.getItineraryItems(itineraryId);
      }
    } catch (e) {
      _error = _message(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteItem(int id) async {
    _error = null;

    try {
      await _repository.deleteItineraryItem(id);
      _items = _items.where((item) => item.id != id).toList();
    } catch (e) {
      _error = _message(e);
    } finally {
      notifyListeners();
    }
  }

  int? _itineraryIdFor(int itemId) {
    for (final item in _items) {
      if (item.id == itemId) return item.itineraryId;
    }
    return _items.isNotEmpty ? _items.first.itineraryId : null;
  }

  String _message(Object e) => e.toString().replaceFirst('Exception: ', '');
}
