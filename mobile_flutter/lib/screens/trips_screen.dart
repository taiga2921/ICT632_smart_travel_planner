import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/app_models.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import 'create_trip_screen.dart';
import 'trip_detail_screen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TripProvider>().loadTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trips'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Current'),
              Tab(text: 'Planned'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _TripList(trips: tripProvider.allTrips, emptyLabel: 'No trips yet'),
              _TripList(
                trips: tripProvider.ongoingTrips,
                emptyLabel: 'No trips in progress',
              ),
              _TripList(
                trips: tripProvider.plannedTrips,
                emptyLabel: 'No planned trips',
              ),
              _TripList(
                trips: tripProvider.completedTrips,
                emptyLabel: 'No completed trips',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final provider = context.read<TripProvider>();
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateTripScreen()),
            );
            await provider.loadTrips();
          },
          icon: const Icon(Icons.add),
          label: const Text('New Trip'),
        ),
      ),
    );
  }
}

class _TripList extends StatelessWidget {
  final List<TripModel> trips;
  final String emptyLabel;

  const _TripList({required this.trips, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();

    if (tripProvider.isLoading && trips.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: tripProvider.loadTrips,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
        children: [
          if (tripProvider.error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.danger),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tripProvider.error!,
                      style: const TextStyle(color: AppColors.danger, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          if (trips.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.route_outlined, size: 42, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text(
                    emptyLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap the + button to plan a new trip.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          else
            ...trips.map(
              (trip) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TripCard(
                  trip: trip,
                  onTap: () {
                    context.read<TripProvider>().selectTrip(trip);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TripDetailScreen(trip: trip),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
