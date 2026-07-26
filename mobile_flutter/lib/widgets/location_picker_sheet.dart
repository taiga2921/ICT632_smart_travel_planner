import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/location_service.dart';

/// Cascading country → state → city picker. Pops with a
/// `"City, State, Country"` string once all three are chosen.
class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationPickerSheet(),
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final LocationService _service = LocationService();

  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _cities = [];

  Map<String, dynamic>? _country;
  Map<String, dynamic>? _state;
  String? _city;

  bool _loadingCountries = false;
  bool _loadingStates = false;
  bool _loadingCities = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<String> _token() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception('You must be signed in');
    return token;
  }

  Future<void> _loadCountries() async {
    setState(() {
      _loadingCountries = true;
      _error = null;
    });

    try {
      final countries = await _service.getCountries(await _token());
      countries.sort((a, b) => '${a['name']}'.compareTo('${b['name']}'));
      if (!mounted) return;
      setState(() => _countries = countries);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingCountries = false);
    }
  }

  Future<void> _loadStates(String ciso) async {
    setState(() {
      _loadingStates = true;
      _error = null;
      _states = [];
      _cities = [];
      _state = null;
      _city = null;
    });

    try {
      final states = await _service.getStates(await _token(), ciso);
      states.sort((a, b) => '${a['name']}'.compareTo('${b['name']}'));
      if (!mounted) return;
      setState(() => _states = states);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingStates = false);
    }
  }

  Future<void> _loadCities(String ciso, String siso) async {
    setState(() {
      _loadingCities = true;
      _error = null;
      _cities = [];
      _city = null;
    });

    try {
      final cities = await _service.getCities(await _token(), ciso, siso);
      cities.sort((a, b) => '${a['name']}'.compareTo('${b['name']}'));
      if (!mounted) return;
      setState(() => _cities = cities);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  bool get _canConfirm => _country != null && _state != null && _city != null;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose a country, state and city.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
            ],
            _Dropdown<Map<String, dynamic>>(
              label: 'Country',
              icon: Icons.public,
              isLoading: _loadingCountries,
              value: _country,
              items: _countries,
              itemLabel: (item) => '${item['name']}',
              onChanged: (item) {
                setState(() => _country = item);
                if (item != null) _loadStates('${item['iso2']}');
              },
            ),
            const SizedBox(height: 14),
            _Dropdown<Map<String, dynamic>>(
              label: 'State',
              icon: Icons.map_outlined,
              isLoading: _loadingStates,
              enabled: _country != null,
              value: _state,
              items: _states,
              itemLabel: (item) => '${item['name']}',
              onChanged: (item) {
                setState(() => _state = item);
                if (item != null && _country != null) {
                  _loadCities('${_country!['iso2']}', '${item['iso2']}');
                }
              },
            ),
            const SizedBox(height: 14),
            _Dropdown<String>(
              label: 'City',
              icon: Icons.location_city_outlined,
              isLoading: _loadingCities,
              enabled: _state != null,
              value: _city,
              items: _cities.map((item) => '${item['name']}').toList(),
              itemLabel: (item) => item,
              onChanged: (item) => setState(() => _city = item),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _canConfirm
                  ? () => Navigator.of(context).pop(
                        '$_city, ${_state!['name']}, ${_country!['name']}',
                      )
                  : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Use this location'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final bool enabled;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.label,
    required this.icon,
    required this.isLoading,
    this.enabled = true,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // A controlled DropdownButton is used instead of DropdownButtonFormField so
    // that clearing the state/city when the parent changes actually resets the
    // visible selection.
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          hint: Text('Select ${label.toLowerCase()}'),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: enabled && !isLoading ? onChanged : null,
        ),
      ),
    );
  }
}
