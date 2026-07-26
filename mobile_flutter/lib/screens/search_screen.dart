import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'destination_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openDestination() {
    final destination = _controller.text.trim();
    if (destination.isEmpty) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DestinationDetailScreen(destinationName: destination),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search destinations')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _openDestination(),
                decoration: const InputDecoration(
                  hintText: 'Search for a city or destination',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _openDestination,
                icon: const Icon(Icons.travel_explore),
                label: const Text('Explore destination'),
              ),
              const SizedBox(height: 32),
              const Icon(Icons.map_outlined, size: 56, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              const Text(
                'Enter a destination to see its attractions, hotels, restaurants and weather.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
