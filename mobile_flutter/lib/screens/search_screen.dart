import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../mock/mock_data.dart';
import 'destination_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = MockData.destinations.where((destination) => destination.title.toLowerCase().contains(_query.toLowerCase()) || destination.country.toLowerCase().contains(_query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Search destinations')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search for a destination',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: results.isEmpty ? 1 : results.length,
                itemBuilder: (context, index) {
                  if (results.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                      child: const Center(child: Text('No destinations match your search.')),
                    );
                  }
                  final destination = results[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(destination.title),
                      subtitle: Text(destination.country),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DestinationDetailScreen(destinationName: destination.title))),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
