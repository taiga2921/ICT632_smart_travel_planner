import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../mock/mock_data.dart';
import '../models/app_models.dart';
import '../providers/trip_provider.dart';
import 'trip_detail_screen.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _pageController = PageController();
  int _step = 0;
  final _destinationController = TextEditingController(text: 'Bali');
  final _countryController = TextEditingController(text: 'Indonesia');
  final _budgetController = TextEditingController(text: '2200');
  final _travelersController = TextEditingController(text: '2');
  final _transportController = TextEditingController(text: 'Flight');
  final _accommodationController = TextEditingController(text: 'Boutique hotel');
  final _notesController = TextEditingController(text: 'Relaxing island escape with spa time.');
  final _styleController = TextEditingController(text: 'Balanced comfort');
  DateTimeRange _range = DateTimeRange(start: DateTime.now().add(const Duration(days: 14)), end: DateTime.now().add(const Duration(days: 20)));

  @override
  void dispose() {
    _pageController.dispose();
    _destinationController.dispose();
    _countryController.dispose();
    _budgetController.dispose();
    _travelersController.dispose();
    _transportController.dispose();
    _accommodationController.dispose();
    _notesController.dispose();
    _styleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create trip')),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / 6, backgroundColor: AppColors.border, color: AppColors.primary),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (value) => setState(() => _step = value),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                  _buildStep6(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Destination', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(controller: _destinationController, decoration: const InputDecoration(labelText: 'Destination')),
          const SizedBox(height: 16),
          TextField(controller: _countryController, decoration: const InputDecoration(labelText: 'Country')),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: MockData.destinations.map((destination) => InkWell(
              onTap: () {
                _destinationController.text = destination.title;
                _countryController.text = destination.country;
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Text(destination.title),
              ),
            )).toList(),
          ),
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              FilledButton.icon(onPressed: () => _advance(), icon: const Icon(Icons.arrow_forward), label: const Text('Next')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Travel dates', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDateRange,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${_range.start.day}/${_range.start.month}/${_range.start.year} - ${_range.end.day}/${_range.end.month}/${_range.end.year}')),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: () => _back(), child: const Text('Back')),
              const Spacer(),
              FilledButton.icon(onPressed: () => _advance(), icon: const Icon(Icons.arrow_forward), label: const Text('Next')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Travel details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(controller: _travelersController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Number of travelers')),
          const SizedBox(height: 16),
          TextField(controller: _transportController, decoration: const InputDecoration(labelText: 'Transportation')),
          const SizedBox(height: 16),
          TextField(controller: _accommodationController, decoration: const InputDecoration(labelText: 'Accommodation')),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: () => _back(), child: const Text('Back')),
              const Spacer(),
              FilledButton.icon(onPressed: () => _advance(), icon: const Icon(Icons.arrow_forward), label: const Text('Next')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget and notes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(controller: _budgetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Estimated budget')),
          const SizedBox(height: 16),
          TextField(controller: _notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'Travel notes')),
          const SizedBox(height: 16),
          TextField(controller: _styleController, decoration: const InputDecoration(labelText: 'Travel style')),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: () => _back(), child: const Text('Back')),
              const Spacer(),
              FilledButton.icon(onPressed: () => _advance(), icon: const Icon(Icons.arrow_forward), label: const Text('Next')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReviewRow(label: 'Destination', value: _destinationController.text),
                _ReviewRow(label: 'Country', value: _countryController.text),
                _ReviewRow(label: 'Dates', value: '${_range.start.day}/${_range.start.month} - ${_range.end.day}/${_range.end.month}'),
                _ReviewRow(label: 'Travelers', value: _travelersController.text),
                _ReviewRow(label: 'Budget', value: _budgetController.text),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: () => _back(), child: const Text('Back')),
              const Spacer(),
              FilledButton.icon(onPressed: () => _advance(), icon: const Icon(Icons.check_circle_outline), label: const Text('Confirm')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep6() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 56, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('Trip created', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Your ${_destinationController.text} itinerary is ready to explore.', style: TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
              const Spacer(),
              FilledButton.icon(onPressed: _saveTrip, icon: const Icon(Icons.save_outlined), label: const Text('Save trip')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), initialDateRange: _range);
    if (range != null) {
      setState(() => _range = range);
    }
  }

  void _advance() {
    if (_step < 5) {
      _pageController.animateToPage(_step + 1, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _back() {
    if (_step > 0) {
      _pageController.animateToPage(_step - 1, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  Future<void> _saveTrip() async {
    final tripProvider = context.read<TripProvider>();
    final trip = Trip(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      title: '${_destinationController.text} Escape',
      destination: _destinationController.text,
      country: _countryController.text,
      startDate: _range.start,
      endDate: _range.end,
      budget: double.tryParse(_budgetController.text) ?? 2200,
      currency: 'USD',
      note: _notesController.text,
      days: [],
      expenses: [],
      imageUrl: MockData.destinations.firstWhere((item) => item.title.toLowerCase() == _destinationController.text.toLowerCase(), orElse: () => MockData.destinations.first).imageUrl,
      status: 'upcoming',
      progress: 0.3,
    );
    await tripProvider.addTrip(trip);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: trip.id)));
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: AppColors.textSecondary))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
