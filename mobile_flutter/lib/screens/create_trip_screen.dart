import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/trip_provider.dart';
import '../widgets/trip_form.dart';

class CreateTripScreen extends StatelessWidget {
  const CreateTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create trip')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            TripForm(
              submitLabel: 'Create trip',
              onSubmit: (data) => _createTrip(context, data),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTrip(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final tripProvider = context.read<TripProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await tripProvider.createTrip(data);

    if (tripProvider.error != null) {
      messenger.showSnackBar(SnackBar(content: Text(tripProvider.error!)));
      return;
    }

    await tripProvider.loadTrips();

    if (!context.mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Trip created successfully')),
    );
    navigator.pop();
  }
}
