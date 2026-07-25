import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/trip_provider.dart';
import 'create_trip_screen.dart';
import 'search_screen.dart';
import 'trip_detail_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _query = '';
  String _sortBy = 'date';

  @override
  void initState() {
    super.initState();
    // 3 tabs: All, Upcoming, Completed
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TripProvider>().loadTrips();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final trips = _filteredTrips(tripProvider.trips);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: tripProvider.loadTrips,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              // Search field
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search destination',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                    icon: const Icon(Icons.filter_list_rounded),
                  ),
                ),
                onChanged: (value) => setState(() => _query = value.toLowerCase()),
              ),
              const SizedBox(height: 16),

              // Sort chips (optional – kept as is)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'Date',
                    selected: _sortBy == 'date',
                    onTap: () => setState(() => _sortBy = 'date'),
                  ),
                  _FilterChip(
                    label: 'Budget',
                    selected: _sortBy == 'budget',
                    onTap: () => setState(() => _sortBy = 'budget'),
                  ),
                  _FilterChip(
                    label: 'Destination',
                    selected: _sortBy == 'destination',
                    onTap: () => setState(() => _sortBy = 'destination'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tabs: All, Upcoming, Completed
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                ],
              ),
              const SizedBox(height: 16),

              // Trip list
              if (tripProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (trips.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.route_outlined,
                        size: 42,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No trips found',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Try a different search or create a new trip.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                ...trips.map((trip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HistoryTripCard(
                        trip: trip,
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          await tripProvider.selectTrip(trip.id);
                          if (!mounted) return;
                          navigator.push(
                            MaterialPageRoute(
                              builder: (_) => TripDetailScreen(tripId: trip.id),
                            ),
                          );
                        },
                      ),
                    )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateTripScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
      ),
    );
  }

  List<Trip> _filteredTrips(List<Trip> source) {
    final tab = _tabController.index;
    // Map tab index to status filter:
    // 0 -> all, 1 -> upcoming, 2 -> completed
    final statusFilter = ['all', 'upcoming', 'completed'][tab];

    var filtered = source.where((trip) {
      final matchesTab = statusFilter == 'all' ||
          trip.status.toLowerCase() == statusFilter;
      final matchesQuery = _query.isEmpty ||
          trip.destination.toLowerCase().contains(_query) ||
          trip.country.toLowerCase().contains(_query);
      return matchesTab && matchesQuery;
    }).toList();

    // Sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'budget':
          return b.budget.compareTo(a.budget);
        case 'destination':
          return a.destination.compareTo(b.destination);
        default:
          return a.startDate.compareTo(b.startDate);
      }
    });

    return filtered;
  }
}

// ---- Custom filter chip (unchanged) ----
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ---- New custom trip card for history (shows only title, destination, dates) ----
class _HistoryTripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;

  const _HistoryTripCard({
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                trip.destination,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${_formatDate(trip.startDate)} – ${_formatDate(trip.endDate)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Simple formatting – you can replace with intl if needed
    return '${date.day}/${date.month}/${date.year}';
  }
}