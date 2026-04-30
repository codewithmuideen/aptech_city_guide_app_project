import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/city_provider.dart';
import '../../widgets/city_card.dart';

class CitySelectionScreen extends StatelessWidget {
  final bool isInitialSelection;
  const CitySelectionScreen({super.key, this.isInitialSelection = false});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CityProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a City'),
        automaticallyImplyLeading: !isInitialSelection,
      ),
      body: p.cities.isEmpty
          ? const Center(child: Text('No cities available'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: p.cities.length,
              itemBuilder: (_, i) {
                final c = p.cities[i];
                return CityCard(
                  city: c,
                  onTap: () {
                    context.read<CityProvider>().selectCity(c.id);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
    );
  }
}
