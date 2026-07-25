import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../mock/mock_data.dart';
import 'attraction_detail_screen.dart';

class AttractionsScreen extends StatelessWidget {
  const AttractionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attractions')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: MockData.attractions.length,
          itemBuilder: (context, index) {
            final attraction = MockData.attractions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.place, color: AppColors.primary)),
                title: Text(attraction.name),
                subtitle: Text(attraction.category),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AttractionDetailScreen(attraction: attraction))),
              ),
            );
          },
        ),
      ),
    );
  }
}
