import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/city.dart';

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
              child: CachedNetworkImage(
                imageUrl: city.imageUrl,
                fit: BoxFit.cover,
                placeholder: (c, u) =>
                    Container(color: Colors.grey.shade300),
                errorWidget: (c, u, e) =>
                    Container(color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
              ),
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
