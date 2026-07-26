import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/attraction_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/country_provider.dart';
import '../providers/hotel_provider.dart';
import '../providers/itinerary_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/trip_provider.dart';
import '../providers/weather_provider.dart';
import '../screens/attraction_detail_screen.dart';
import '../screens/attractions_screen.dart';
import '../screens/budget_screen.dart';
import '../screens/country_screen.dart';
import '../screens/create_trip_screen.dart';
import '../screens/hotel_detail_screen.dart';
import '../screens/hotel_screen.dart';
import '../screens/itinerary_screen.dart';
import '../screens/restaurant_detail_screen.dart';
import '../screens/restaurant_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/trip_detail_screen.dart';
import '../screens/trips_screen.dart';
import '../screens/weather_screen.dart';
import '../theme/app_theme.dart';

class SmartTravelPlannerApp extends StatelessWidget {
  const SmartTravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => AttractionProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => ItineraryProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Travel Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/weather': (_) => const WeatherScreen(),
          '/attractions': (_) => const AttractionsScreen(),
          '/hotels': (_) => const HotelScreen(),
          '/restaurants': (_) => const RestaurantScreen(),
          '/country': (_) => const CountryScreen(),
          '/trips': (_) => const TripsScreen(),
          '/create-trip': (_) => const CreateTripScreen(),
          // The screens below read their model from the route arguments and
          // fall back to the currently selected trip when none is supplied.
          '/trip-detail': (_) => const TripDetailScreen(),
          '/itinerary': (_) => const ItineraryScreen(),
          '/budget': (_) => const BudgetScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/attraction-detail':
              final attraction = settings.arguments as AttractionResult;
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => AttractionDetailScreen(attraction: attraction),
              );
            case '/hotel-detail':
              final hotel = settings.arguments as HotelResult;
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => HotelDetailScreen(hotel: hotel),
              );
            case '/restaurant-detail':
              final restaurant = settings.arguments as RestaurantResult;
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => RestaurantDetailScreen(restaurant: restaurant),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
