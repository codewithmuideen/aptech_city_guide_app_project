import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../models/attraction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/city_provider.dart';
import '../../widgets/attraction_card.dart';
import '../../widgets/empty_state.dart';
import '../attractions/attraction_detail_screen.dart';
import '../attractions/attraction_list_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';
import 'city_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<CityProvider>();
      if (p.selectedCityId == null && p.cities.isNotEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const CitySelectionScreen(isInitialSelection: true)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      AttractionListScreen(),
      SearchScreen(),
      _FavoritesScreen(),
      ProfileScreen(),
    ];
    return Scaffold(
      body: screens[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _FavoritesScreen extends StatelessWidget {
  const _FavoritesScreen();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final city = context.watch<CityProvider>();
    final favorites = city.attractions
        .where((a) => auth.user?.favoriteAttractions.contains(a.id) ?? false)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: favorites.isEmpty
          ? EmptyState(
              icon: Icons.favorite_outline,
              title: 'No favorites yet',
              message:
                  'Tap the heart icon on any attraction you like and it will be waiting for you here.',
            )
          : MasonryGridView.count(
              padding: const EdgeInsets.all(10),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              itemCount: favorites.length,
              itemBuilder: (_, i) {
                final a = favorites[i];
                return AttractionCard(
                  attraction: a,
                  rating: city.averageRating(a.id),
                  reviewCount: city.reviewsFor(a.id).length,
                  isFavorite: true,
                  onFavoriteToggle: () =>
                      context.read<AuthProvider>().toggleFavorite(a.id),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          AttractionDetailScreen(attraction: a))),
                );
              },
            ),
    );
  }
}
