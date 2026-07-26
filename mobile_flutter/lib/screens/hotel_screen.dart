import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../app_config.dart';
import '../constants/app_colors.dart';
import '../providers/hotel_provider.dart';
import '../widgets/result_card.dart';

class HotelScreen extends StatefulWidget {
  final String? initialLocation;

  const HotelScreen({super.key, this.initialLocation});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  static final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('d MMM yyyy');

  late final TextEditingController _queryController;
  final _formKey = GlobalKey<FormState>();

  DateTime _checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 3));

  @override
  void initState() {
    super.initState();
    final location = widget.initialLocation ?? AppConfig.defaultLocationName;
    _queryController = TextEditingController(text: 'hotels in $location');
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final firstDate = isCheckIn ? DateTime.now() : _checkIn.add(const Duration(days: 1));
    final initialDate = isCheckIn ? _checkIn : _checkOut;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (!_checkOut.isAfter(_checkIn)) {
          _checkOut = _checkIn.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  void _search() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<HotelProvider>().fetchHotels(
          query: _queryController.text.trim(),
          checkIn: _apiFormat.format(_checkIn),
          checkOut: _apiFormat.format(_checkOut),
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Hotels')),
      body: SafeArea(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _queryController,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) => _search(),
                      decoration: const InputDecoration(
                        labelText: 'Search hotels',
                        hintText: 'e.g. hotels in Kuala Lumpur',
                        prefixIcon: Icon(Icons.hotel_outlined),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Enter a search term'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DateField(
                            label: 'Check-in',
                            value: _displayFormat.format(_checkIn),
                            onTap: () => _pickDate(isCheckIn: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateField(
                            label: 'Check-out',
                            value: _displayFormat.format(_checkOut),
                            onTap: () => _pickDate(isCheckIn: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: provider.isLoading ? null : _search,
                        icon: const Icon(Icons.search),
                        label: const Text('Search hotels'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: _buildResults(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(HotelProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return _MessageState(icon: Icons.error_outline, message: provider.error!);
    }

    if (provider.hotels.isEmpty) {
      return const _MessageState(
        icon: Icons.hotel_outlined,
        message: 'Search for hotels to see availability and prices.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: provider.hotels.length,
      itemBuilder: (context, index) {
        final hotel = provider.hotels[index];
        return ResultCard(
          thumbnail: hotel.thumbnail,
          fallbackIcon: Icons.hotel_outlined,
          title: hotel.name,
          subtitle: hotel.description,
          rating: hotel.rating,
          reviews: hotel.reviews,
          trailingLabel: hotel.price != null ? '${hotel.price} / night' : null,
          onTap: () => Navigator.of(context).pushNamed('/hotel-detail', arguments: hotel),
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
