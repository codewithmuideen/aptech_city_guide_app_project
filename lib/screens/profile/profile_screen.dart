import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/city_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/profile_avatar.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final city = context.watch<CityProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    final reviewsPosted =
        city.reviews.where((r) => r.userId == user.id).length;
    final favoritesCount = user.favoriteAttractions.length;
    final favCityCount = _favoriteCities(user, city).length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _ProfileHero(
              user: user,
              reviewsPosted: reviewsPosted,
              favoritesCount: favoritesCount,
              citiesExplored: favCityCount,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _SectionCard(children: [
                    _Item(
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      subtitle: 'Name, email, phone, avatar',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const EditProfileScreen())),
                    ),
                  ]),
                  _SectionCard(children: [
                    SwitchListTile(
                      secondary:
                          const Icon(Icons.notifications_outlined),
                      title: const Text('Notifications'),
                      subtitle: const Text(
                          'Show toasts when you favorite, review, etc.'),
                      value: user.notificationsEnabled,
                      onChanged: (v) {
                        user.notificationsEnabled = v;
                        context.read<AuthProvider>().updateUser(user);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Dark Mode'),
                      value: theme.mode == ThemeMode.dark,
                      onChanged: (_) => context.read<ThemeProvider>().toggle(),
                    ),
                  ]),
                  _SectionCard(children: [
                    _Item(
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'Version, credits, team',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'City Guide',
                        applicationVersion: '1.0.0',
                        applicationLegalese:
                            'Built with Flutter - eProject submission.\n\n'
                            'Team:\n'
                            '  1599306 - Vincent Biodun Olowokande\n'
                            '  1599738 - Hikmat Adeshewa Raji\n'
                            '  1599290 - Michael Dolapo Obawa\n'
                            '  1424591 - Abdulkhaliq Olayinka Amototo',
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign out'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              icon: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.logout,
                                    color: Colors.red, size: 32),
                              ),
                              title: const Text('Sign out?'),
                              content: const Text(
                                'You will need to log in again to access your account.',
                                textAlign: TextAlign.center,
                              ),
                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel')),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  icon: const Icon(Icons.logout, size: 18),
                                  label: const Text('Sign out'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true || !context.mounted) return;
                          await context.read<AuthProvider>().logout();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (_) => false,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _favoriteCities(dynamic user, CityProvider city) {
    final ids = (user.favoriteAttractions as List).toSet();
    final attractions = city.attractions.where((a) => ids.contains(a.id));
    final cityIds = attractions.map((a) => a.cityId).toSet();
    return city.cities.where((c) => cityIds.contains(c.id)).map((c) => c.name).toList();
  }
}

class _ProfileHero extends StatelessWidget {
  final dynamic user;
  final int reviewsPosted;
  final int favoritesCount;
  final int citiesExplored;

  const _ProfileHero({
    required this.user,
    required this.reviewsPosted,
    required this.favoritesCount,
    required this.citiesExplored,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          Row(
            children: [
              ProfileAvatar(
                  name: user.name, base64Image: user.profileImage, size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(user.email,
                        style: const TextStyle(color: Colors.white70)),
                    if (user.isAdmin) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('ADMIN',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: Row(children: [
              Expanded(
                  child:
                      _StatCell(value: reviewsPosted, label: 'Reviews')),
              _Sep(),
              Expanded(
                  child:
                      _StatCell(value: favoritesCount, label: 'Favorites')),
              _Sep(),
              Expanded(
                  child:
                      _StatCell(value: citiesExplored, label: 'Cities')),
            ]),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final int value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _Sep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white24,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(children: children),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
