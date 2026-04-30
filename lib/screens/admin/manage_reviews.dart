import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/city_provider.dart';
import '../../widgets/profile_avatar.dart';

class ManageReviewsScreen extends StatefulWidget {
  const ManageReviewsScreen({super.key});

  @override
  State<ManageReviewsScreen> createState() => _ManageReviewsScreenState();
}

class _ManageReviewsScreenState extends State<ManageReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CityProvider>().load();
    });
  }

  Future<void> _refresh() => context.read<CityProvider>().load();

  @override
  Widget build(BuildContext context) {
    final city = context.watch<CityProvider>();
    final reviews = List.of(city.reviews)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Reviews (${reviews.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh from storage',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: reviews.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'No reviews yet.\n\nReviews submitted by any signed-in user will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final r = reviews[i];
                  final target = city.attractions.firstWhere(
                    (a) => a.id == r.attractionId,
                    orElse: () => city.attractions.isNotEmpty
                        ? city.attractions.first
                        : throw Exception(),
                  );
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ProfileAvatar(name: r.userName, size: 40),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.userName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      'on ${target.name} - ${DateFormat.yMMMd().add_jm().format(r.createdAt)}',
                                      style: TextStyle(
                                          color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              RatingBarIndicator(
                                rating: r.rating,
                                itemCount: 5,
                                itemSize: 16,
                                itemBuilder: (_, __) =>
                                    const Icon(Icons.star, color: Colors.amber),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(r.comment),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.thumb_up_outlined,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${r.likeCount} helpful',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                            const Spacer(),
                            TextButton.icon(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              label: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () => context
                                  .read<CityProvider>()
                                  .deleteReview(r.id),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
