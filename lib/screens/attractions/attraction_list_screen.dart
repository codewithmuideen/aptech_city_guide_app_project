import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../models/attraction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/city_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/attraction_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/greeting_header.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/smart_image.dart';
import '../home/city_selection_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import 'attraction_detail_screen.dart';

class AttractionListScreen extends StatefulWidget {
  const AttractionListScreen({super.key});

  @override
  State<AttractionListScreen> createState() => _AttractionListScreenState();
}

class _AttractionListScreenState extends State<AttractionListScreen> {
  String _categoryLabel = 'All';
  String _sortBy = 'rating';

  AttractionCategory? get _categoryFilter =>
      _categoryLabel == 'All' ? null : AttractionCategoryX.fromLabel(_categoryLabel);

  void _changeCity() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CitySelectionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final city = context.watch<CityProvider>();
    final auth = context.watch<AuthProvider>();
    final selected = city.selectedCity;
    final items = city.filterSort(category: _categoryFilter, sortBy: _sortBy);
    final topRated = city
        .filterSort(sortBy: 'rating')
        .where((a) => city.averageRating(a.id) > 0)
        .take(6)
        .toList();

    return Scaffold(
      body: city.cities.isEmpty
          ? const ShimmerGrid(count: 6)
          : RefreshIndicator(
              onRefresh: () => city.load(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: GreetingHeader(
                      user: auth.user,
                      city: selected,
                      onChangeCity: _changeCity,
                      onOpenProfile: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen())),
                    ),
                  ),
                  if (topRated.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        title: 'Top rated',
                        trailing: TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => MapScreen(
                                      attractions: items,
                                      center: selected))),
                          icon: const Icon(Icons.map_outlined, size: 16),
                          label: const Text('View on map'),
                        ),
                      ),
                    ),
                  if (topRated.isNotEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 190,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          itemCount: topRated.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final a = topRated[i];
                            return _TopRatedCard(
                              attraction: a,
                              rating: city.averageRating(a.id),
                              reviewCount: city.reviewsFor(a.id).length,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) =>
                                        AttractionDetailScreen(attraction: a)));
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                      child: Row(children: [
                        const Expanded(
                          child: Text('All places',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.sort),
                          onSelected: (v) => setState(() => _sortBy = v),
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'rating',
                                child: Text('Sort by Rating')),
                            PopupMenuItem(
                                value: 'name', child: Text('Sort by Name')),
                          ],
                        ),
                      ]),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        children: AppConstants.categories.map((c) {
                          final selectedChip = _categoryLabel == c;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(c),
                              selected: selectedChip,
                              onSelected: (_) {
                                HapticFeedback.selectionClick();
                                setState(() => _categoryLabel = c);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.search_off,
                        title: 'Nothing here yet',
                        message:
                            'Try a different category or pick another city.',
                        actionLabel: 'Change city',
                        onAction: _changeCity,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childCount: items.length,
                        itemBuilder: (_, i) {
                          final a = items[i];
                          final favorite = auth.user?.favoriteAttractions
                                  .contains(a.id) ??
                              false;
                          return AttractionCard(
                            attraction: a,
                            rating: city.averageRating(a.id),
                            reviewCount: city.reviewsFor(a.id).length,
                            isFavorite: favorite,
                            onFavoriteToggle: () {
                              HapticFeedback.lightImpact();
                              context.read<AuthProvider>().toggleFavorite(a.id);
                            },
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) =>
                                      AttractionDetailScreen(attraction: a)));
                            },
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _TopRatedCard extends StatelessWidget {
  final Attraction attraction;
  final double rating;
  final int reviewCount;
  final VoidCallback onTap;

  const _TopRatedCard({
    required this.attraction,
    required this.rating,
    required this.reviewCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Hero(
              tag: 'attraction-${attraction.id}',
              child: SmartImage(
                source: attraction.imageUrl,
                width: 230,
                height: 190,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(attraction.category.label,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ),
                const SizedBox(height: 6),
                Text(attraction.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 4)
                        ])),
                const SizedBox(height: 4),
                Row(children: [
                  RatingBarIndicator(
                    rating: rating,
                    itemCount: 5,
                    itemSize: 14,
                    itemBuilder: (_, __) =>
                        const Icon(Icons.star, color: Colors.amber),
                  ),
                  const SizedBox(width: 4),
                  Text('${rating.toStringAsFixed(1)} ($reviewCount)',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
