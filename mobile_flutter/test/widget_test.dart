import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/models/app_models.dart';
import 'package:mobile_flutter/widgets/trip_card.dart';

TripModel buildTrip({String status = 'planned'}) {
  return TripModel(
    id: 1,
    userId: 1,
    title: 'Penang Food Trip',
    destinationName: 'George Town, Penang, Malaysia',
    startDate: '2026-08-01',
    endDate: '2026-08-05',
    budget: 1500,
    currency: 'MYR',
    status: status,
  );
}

void main() {
  test('trip status labels match the backend enum', () {
    expect(TripStatus.label('planned'), 'Planned');
    expect(TripStatus.label('ongoing'), 'Current');
    expect(TripStatus.label('completed'), 'Completed');
  });

  test('trip model parses backend JSON', () {
    final trip = TripModel.fromJson({
      'id': 7,
      'user_id': 2,
      'title': 'Tokyo',
      'destination_name': 'Shibuya, Tokyo, Japan',
      'start_date': '2026-09-01',
      'end_date': '2026-09-07',
      'budget': '4200.00',
      'currency': 'JPY',
      'notes': null,
      'status': 'ongoing',
      'created_at': '2026-07-01 10:00:00',
    });

    expect(trip.id, 7);
    expect(trip.budget, 4200.0);
    expect(trip.dayCount, 7);
    expect(trip.status, 'ongoing');
  });

  testWidgets('trip card renders the trip summary', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TripCard(trip: buildTrip(status: 'ongoing'), onTap: () {}),
        ),
      ),
    );

    expect(find.text('Penang Food Trip'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('George Town, Penang, Malaysia'), findsOneWidget);
  });
}
