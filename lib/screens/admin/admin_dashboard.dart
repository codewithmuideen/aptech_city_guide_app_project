import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_users_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/city_provider.dart';
import '../auth/login_screen.dart';
import 'manage_cities.dart';
import 'manage_attractions.dart';
import 'manage_reviews.dart';
import 'manage_users.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAll());
  }

  Future<void> _refreshAll() async {
    await context.read<CityProvider>().load();
    if (!mounted) return;
    await context.read<AdminUsersProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final city = context.watch<CityProvider>();
    final usersProvider = context.watch<AdminUsersProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh stats',
            onPressed: _refreshAll,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Welcome, Administrator',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Manage cities, attractions, and reviews',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: _StatCard(
                  icon: Icons.group,
                  label: 'Users',
                  value: usersProvider.users.length),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                  icon: Icons.location_city,
                  label: 'Cities',
                  value: city.cities.length),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                  icon: Icons.place,
                  label: 'Attractions',
                  value: city.attractions.length),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                  icon: Icons.rate_review,
                  label: 'Reviews',
                  value: city.reviews.length),
            ),
          ]),
          const SizedBox(height: 24),
          _MenuTile(
            icon: Icons.group,
            title: 'Manage Users',
            subtitle: 'View registered users, grant admin, delete accounts',
            color: Colors.teal,
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
          ),
          _MenuTile(
            icon: Icons.location_city,
            title: 'Manage Cities',
            subtitle: 'Add, edit, or remove cities',
            color: Colors.blue,
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageCitiesScreen())),
          ),
          _MenuTile(
            icon: Icons.place,
            title: 'Manage Attractions',
            subtitle: 'Attractions, restaurants, hotels, events',
            color: Colors.orange,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ManageAttractionsScreen())),
          ),
          _MenuTile(
            icon: Icons.rate_review,
            title: 'Manage Reviews',
            subtitle: 'Moderate user-submitted reviews',
            color: Colors.green,
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageReviewsScreen())),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  const _StatCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text('$value',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
