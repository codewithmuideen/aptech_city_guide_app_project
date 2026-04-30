import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/attraction.dart';
import '../../models/city.dart';

class MapScreen extends StatelessWidget {
  final List<Attraction> attractions;
  final City? center;

  const MapScreen({super.key, required this.attractions, this.center});

  Future<void> _openInMaps(double lat, double lng, String label) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openDirections(double lat, double lng) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map${center != null ? ' - ${center!.name}' : ''}')),
      body: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map, size: 64, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  center != null ? 'Attractions in ${center!.name}' : 'Attraction Map',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('${attractions.length} locations',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: attractions.length,
              itemBuilder: (_, i) {
                final a = attractions[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text('${i + 1}', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(a.name),
                  subtitle: Text('${a.address}\n${a.latitude.toStringAsFixed(4)}, ${a.longitude.toStringAsFixed(4)}'),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.place_outlined),
                        tooltip: 'View on map',
                        onPressed: () => _openInMaps(a.latitude, a.longitude, a.name),
                      ),
                      IconButton(
                        icon: const Icon(Icons.directions),
                        tooltip: 'Directions',
                        onPressed: () => _openDirections(a.latitude, a.longitude),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
