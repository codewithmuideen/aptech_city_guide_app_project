import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../models/attraction.dart';

class AttractionCard extends StatelessWidget {
  final Attraction attraction;
  final double rating;
  final int reviewCount;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const AttractionCard({
    super.key,
    required this.attraction,
    required this.rating,
    required this.reviewCount,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  Color _categoryColor(BuildContext context) {
    switch (attraction.category) {
      case AttractionCategory.restaurant:
        return Colors.orange;
      case AttractionCategory.hotel:
        return Colors.purple;
      case AttractionCategory.event:
        return Colors.pink;
      case AttractionCategory.attraction:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Hero(
                  tag: 'attraction-${attraction.id}',
                  child: CachedNetworkImage(
                    imageUrl: attraction.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Container(color: Colors.grey.shade300),
                    errorWidget: (c, u, e) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image)),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.25)],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _categoryColor(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(attraction.category.label,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              if (onFavoriteToggle != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ),
            ]),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(attraction.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(attraction.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: rating,
                        itemCount: 5,
                        itemSize: 16,
                        itemBuilder: (c, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                      ),
                      const SizedBox(width: 6),
                      Text(rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Text('($reviewCount)',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
