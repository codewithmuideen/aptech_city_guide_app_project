import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../models/review.dart';
import 'profile_avatar.dart';

class ReviewTile extends StatelessWidget {
  final Review review;
  final bool likedByMe;
  final VoidCallback onLike;

  const ReviewTile({
    super.key,
    required this.review,
    required this.likedByMe,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatar(name: review.userName, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        DateFormat.yMMMd().format(review.createdAt),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                RatingBarIndicator(
                  rating: review.rating,
                  itemCount: 5,
                  itemSize: 16,
                  itemBuilder: (c, _) => const Icon(Icons.star, color: Colors.amber),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment),
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    likedByMe ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 18,
                    color: likedByMe
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  onPressed: onLike,
                ),
                Text('${review.likeCount} helpful'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
