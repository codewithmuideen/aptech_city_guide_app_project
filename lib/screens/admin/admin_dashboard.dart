import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_users_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/city_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/profile_avatar.dart';
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

  /// Trims the displayed greeting so it fits beside the avatar + 3 action
  /// buttons even on narrow phones. "Administrator" -> "Admin"; otherwise
  /// uses the first word of the name.
  String _shortName(String? full) {
    final raw = (full ?? 'Admin').trim();
    if (raw.toLowerCase() == 'administrator') return 'Admin';
    final first = raw.split(RegExp(r'\s+')).first;
    return first.length > 12 ? '${first.substring(0, 12)}.' : first;
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout, color: Colors.red, size: 32),
        ),
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to log in again to access the admin dashboard.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final city = context.watch<CityProvider>();
    final usersProvider = context.watch<AdminUsersProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.mode == ThemeMode.dark;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ----- Gradient hero header -----
            Container(
              padding: EdgeInsets.fromLTRB(
                  18, MediaQuery.of(context).padding.top + 16, 12, 26),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ProfileAvatar(
                        name: auth.user?.name ?? 'Admin',
                        base64Image: auth.user?.profileImage,
                        size: 46,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Admin Dashboard',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  letterSpacing: 0.4),
                            ),
                            Text(
                              'Hi, ${_shortName(auth.user?.name)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _CircleAction(
                        icon: isDark ? Icons.light_mode : Icons.dark_mode,
                        tooltip:
                            isDark ? 'Switch to light mode' : 'Switch to dark mode',
                        onTap: () => context.read<ThemeProvider>().toggle(),
                      ),
                      const SizedBox(width: 6),
                      _CircleAction(
                        icon: Icons.refresh,
                        tooltip: 'Refresh',
                        onTap: _refreshAll,
                      ),
                      const SizedBox(width: 6),
                      _CircleAction(
                        icon: Icons.logout,
                        tooltip: 'Sign out',
                        onTap: _confirmLogout,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.78,
                    children: [
                      _GlassStat(
                          icon: Icons.group,
                          label: 'Users',
                          value: usersProvider.users.length),
                      _GlassStat(
                          icon: Icons.location_city,
                          label: 'Cities',
                          value: city.cities.length),
                      _GlassStat(
                          icon: Icons.place,
                          label: 'Places',
                          value: city.attractions.length),
                      _GlassStat(
                          icon: Icons.rate_review,
                          label: 'Reviews',
                          value: city.reviews.length),
                    ],
                  ),
                ],
              ),
            ),

            // ----- Section title -----
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 22, 18, 8),
              child: Text(
                'Management',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.group,
                    title: 'Manage Users',
                    subtitle:
                        'View registered users, grant admin, edit or delete accounts',
                    color: Colors.teal,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ManageUsersScreen())),
                  ),
                  _MenuTile(
                    icon: Icons.location_city,
                    title: 'Manage Cities',
                    subtitle: 'Add, edit, or remove cities',
                    color: Colors.blue,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ManageCitiesScreen())),
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
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ManageReviewsScreen())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Pull down to refresh stats. Each visitor on the web build has their own local sandbox.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.18),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _GlassStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  const _GlassStat(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          Text('$value',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
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
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.85), color.withOpacity(0.55)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
