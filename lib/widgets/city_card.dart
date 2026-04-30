import 'package:flutter/material.dart';

import '../models/city.dart';
import 'smart_image.dart';

class CityCard extends StatelessWidget {
  final City city;
  final VoidCallback onTap;

  const CityCard({super.key, required this.city, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 160,
              child: SmartImage(source: city.imageUrl),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(city.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.place, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(city.country, style: const TextStyle(color: Colors.grey)),
                  ]),
                  const SizedBox(height: 8),
                  Text(city.description,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
