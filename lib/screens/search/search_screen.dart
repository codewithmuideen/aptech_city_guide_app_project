import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/attraction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/city_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/attraction_card.dart';
import '../attractions/attraction_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String _categoryLabel = 'All';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AttractionCategory? get _category =>
      _categoryLabel == 'All' ? null : AttractionCategoryX.fromLabel(_categoryLabel);

  @override
  Widget build(BuildContext context) {
    final city = context.watch<CityProvider>();
    final auth = context.watch<AuthProvider>();
    final results = city.search(_query, category: _category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search attractions, restaurants, events...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              setState(() => _query = '');
                            },
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: AppConstants.categories.map((c) {
                      final selected = _categoryLabel == c;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c),
                          selected: selected,
                          onSelected: (_) => setState(() => _categoryLabel = c),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: results.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No results. Try a different keyword or category.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final a = results[i];
                return AttractionCard(
                  attraction: a,
                  rating: city.averageRating(a.id),
                  reviewCount: city.reviewsFor(a.id).length,
                  isFavorite:
                      auth.user?.favoriteAttractions.contains(a.id) ?? false,
                  onFavoriteToggle: () =>
                      context.read<AuthProvider>().toggleFavorite(a.id),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AttractionDetailScreen(attraction: a))),
                );
              },
            ),
    );
  }
}
