import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_config.dart';
import '../constants/app_colors.dart';
import '../providers/budget_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/trip_provider.dart';
import '../providers/weather_provider.dart';
import '../utils/location_helper.dart';
import '../utils/weather_utils.dart';
import '../widgets/profile_avatar.dart';
import 'attractions_screen.dart';
import 'profile_screen.dart';
import 'trips_screen.dart';
import 'weather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? _latitude;
  double? _longitude;
  String? _cityName;
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDashboard();
    });
  }

  Future<void> _loadDashboard() async {
    await Future.wait([
      context.read<ProfileProvider>().fetchProfile(),
      _loadTripsAndExpenses(),
      _loadLocationWeather(),
    ]);
  }

  Future<void> _loadTripsAndExpenses() async {
    final tripProvider = context.read<TripProvider>();
    await tripProvider.loadTrips();
    if (!mounted) return;
    await context
        .read<BudgetProvider>()
        .loadAllExpenses(tripProvider.allTrips.map((trip) => trip.id).toList());
  }

  Future<void> _loadLocationWeather() async {
    if (mounted) setState(() => _isLocating = true);

    double latitude = AppConfig.defaultLatitude;
    double longitude = AppConfig.defaultLongitude;
    String? city;

    try {
      final position = await LocationHelper.getCurrentPosition();
      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
        city = await _reverseGeocode(latitude, longitude);
      } else {
        city = AppConfig.defaultLocationName;
      }
    } catch (_) {
      city = null;
    }

    if (!mounted) return;
    setState(() {
      _latitude = latitude;
      _longitude = longitude;
      _cityName = city;
      _isLocating = false;
    });

    await context.read<WeatherProvider>().fetchWeather(latitude, longitude);
  }

  Future<String?> _reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;
      final place = placemarks.first;
      final name = place.locality?.isNotEmpty == true
          ? place.locality
          : place.subAdministrativeArea?.isNotEmpty == true
              ? place.subAdministrativeArea
              : place.administrativeArea;
      return name?.isNotEmpty == true ? name : null;
    } catch (_) {
      return null;
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 18) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  String get _locationLabel {
    if (_isLocating) return '📍 Detecting...';
    if (_cityName != null) return '📍 $_cityName';
    if (_latitude != null && _longitude != null) {
      return '📍 ${_latitude!.toStringAsFixed(2)}, ${_longitude!.toStringAsFixed(2)}';
    }
    return '📍 Your Location';
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final tripProvider = context.watch<TripProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final profile = context.watch<ProfileProvider>().profile;

    final authUser = FirebaseAuth.instance.currentUser;
    final displayName = profile?.name.isNotEmpty == true
        ? profile!.name
        : authUser?.displayName ?? authUser?.email?.split('@').first ?? 'Traveller';
    final photoUrl = profile?.photoUrl.isNotEmpty == true
        ? profile!.photoUrl
        : authUser?.photoURL;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayName.split(' ').first,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  ProfileAvatar(
                    photoUrl: photoUrl,
                    initials: profile?.initials ??
                        displayName.characters.first.toUpperCase(),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.luggage_outlined,
                      label: 'Total Trips',
                      value: '${tripProvider.allTrips.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Total Spent',
                      value: NumberFormat.compactCurrency(
                        symbol: '',
                        decimalDigits: 2,
                      ).format(budgetProvider.totalSpent).trim(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WeatherScreen(
                      location: _cityName ?? 'Your Location',
                      lat: _latitude ?? AppConfig.defaultLatitude,
                      lon: _longitude ?? AppConfig.defaultLongitude,
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(24),
                child: _WeatherSummaryCard(
                  provider: weatherProvider,
                  locationLabel: _locationLabel,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick access',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _ActionCard(
                    icon: Icons.travel_explore_outlined,
                    label: 'Explore Trips',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TripsScreen()),
                    ),
                  ),
                  _ActionCard(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Weather',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WeatherScreen(
                          location: _cityName ?? 'Your Location',
                          lat: _latitude ?? AppConfig.defaultLatitude,
                          lon: _longitude ?? AppConfig.defaultLongitude,
                        ),
                      ),
                    ),
                  ),
                  _ActionCard(
                    icon: Icons.attractions_outlined,
                    label: 'Attractions',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AttractionsScreen(
                          initialLocation: _cityName,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _WeatherSummaryCard extends StatelessWidget {
  final WeatherProvider provider;
  final String locationLabel;

  const _WeatherSummaryCard({
    required this.provider,
    required this.locationLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (provider.isLoading) {
      return const SizedBox(
        height: 110,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final current = provider.currentWeather;

    if (current == null) {
      return SizedBox(
        height: 110,
        child: Center(
          child: Text(
            provider.error != null
                ? 'Weather unavailable. Pull down to retry.'
                : 'Weather data not loaded yet.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locationLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                WeatherCode.icon(current.weathercode),
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${current.temperature.toStringAsFixed(0)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    WeatherCode.label(current.weathercode),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
