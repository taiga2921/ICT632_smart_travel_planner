// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/app/app.dart';
import 'package:mobile_flutter/providers/profile_provider.dart';
import 'package:mobile_flutter/providers/trip_provider.dart';
import 'package:mobile_flutter/providers/weather_provider.dart';
import 'package:mobile_flutter/repositories/trip_repository.dart';
import 'package:mobile_flutter/providers/auth_provider.dart';
import 'package:mobile_flutter/screens/home_screen.dart';
import 'package:mobile_flutter/screens/profile_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('app launches with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartTravelPlannerApp());

    expect(find.text('Smart Travel Planner'), findsOneWidget);
  });

  testWidgets('home dashboard shows quick actions section', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TripProvider(MockTripRepository())),
          ChangeNotifierProvider(create: (_) => WeatherProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quick actions'), findsOneWidget);
  });

  testWidgets('profile screen shows travel preferences', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Travel preferences'), findsOneWidget);
  });
}
