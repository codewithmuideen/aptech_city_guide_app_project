import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/admin_users_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/city_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/profile_avatar.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersProvider>().load();
      context.read<CityProvider>().load();
    });
  }

  Future<void> _refresh() async {
    await context.read<AdminUsersProvider>().load();
    if (!mounted) return;
    await context.read<CityProvider>().load();
  }

  void _openEditor({AppUser? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _UserEditorSheet(existing: existing),
    );
  }

  /// Returns the set of city names this user has an attraction favorited in.
  List<String> _favoriteCities(AppUser u, CityProvider city) {
    final ids = u.favoriteAttractions.toSet();
    final attractions = city.attractions.where((a) => ids.contains(a.id));
    final cityIds = attractions.map((a) => a.cityId).toSet();
    return city.cities
        .where((c) => cityIds.contains(c.id))
        .map((c) => c.name)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentAdminId = context.watch<AuthProvider>().user?.id;
    final provider = context.watch<AdminUsersProvider>();
    final city = context.watch<CityProvider>();
    final users = provider.users;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users (${users.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt),
            tooltip: 'Add user',
            onPressed: () => _openEditor(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Add User'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: users.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                      child: Text('No users yet',
                          style: TextStyle(color: Colors.grey))),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Row(children: [
                    Expanded(
                        child: _StatPill(
                            icon: Icons.group,
                            label: 'Total',
                            value: users.length)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatPill(
                            icon: Icons.verified_user,
                            label: 'Admins',
                            value: provider.adminCount)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatPill(
                            icon: Icons.person,
                            label: 'Regular',
                            value: provider.regularCount)),
                  ]),
                  const SizedBox(height: 14),
                  ...users.map((u) {
                    final isSelf = u.id == currentAdminId;
                    final favCities = _favoriteCities(u, city);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 4, 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ProfileAvatar(
                                    name: u.name,
                                    base64Image: u.profileImage,
                                    size: 48),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Flexible(
                                          child: Text(u.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                        ),
                                        const SizedBox(width: 6),
                                        if (u.isAdmin) _badge('ADMIN', Colors.orange),
                                        if (isSelf) _badge('YOU', Colors.blue),
                                      ]),
                                      Text(u.email,
                                          style:
                                              const TextStyle(fontSize: 13)),
                                      if (u.phone.isNotEmpty)
                                        Text(u.phone,
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12)),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    if (v == 'edit') {
                                      _openEditor(existing: u);
                                    } else if (v == 'toggleAdmin') {
                                      await context
                                          .read<AdminUsersProvider>()
                                          .toggleAdmin(u.id);
                                    } else if (v == 'delete') {
                                      final ok = await _confirmDelete(u.name);
                                      if (ok && context.mounted) {
                                        await context
                                            .read<AdminUsersProvider>()
                                            .deleteUser(u.id);
                                      }
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit user')),
                                    if (!isSelf)
                                      PopupMenuItem(
                                        value: 'toggleAdmin',
                                        child: Text(u.isAdmin
                                            ? 'Revoke admin'
                                            : 'Make admin'),
                                      ),
                                    if (!isSelf)
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete user',
                                            style: TextStyle(color: Colors.red)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _infoChip(Icons.favorite,
                                    '${u.favoriteAttractions.length} favorites'),
                                _infoChip(
                                    u.notificationsEnabled
                                        ? Icons.notifications_active
                                        : Icons.notifications_off,
                                    'Notifications ${u.notificationsEnabled ? "on" : "off"}'),
                                if (favCities.isNotEmpty)
                                  _infoChip(Icons.location_city,
                                      'Cities: ${favCities.join(", ")}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete user?'),
        content: Text('"$name" will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    return ok ?? false;
  }
}

class _UserEditorSheet extends StatefulWidget {
  final AppUser? existing;
  const _UserEditorSheet({this.existing});

  @override
  State<_UserEditorSheet> createState() => _UserEditorSheetState();
}

class _UserEditorSheetState extends State<_UserEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _phone;
  final _password = TextEditingController();
  bool _isAdmin = false;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _isAdmin = e?.isAdmin ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<AdminUsersProvider>();
    String? error;
    if (_isEdit) {
      error = await provider.updateUser(
        id: widget.existing!.id,
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        isAdmin: _isAdmin,
        newPassword: _password.text.trim().isEmpty ? null : _password.text.trim(),
      );
    } else {
      error = await provider.createUser(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
        isAdmin: _isAdmin,
      );
    }
    setState(() => _saving = false);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_isEdit ? 'Edit user' : 'Add new user',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Full name',
                icon: Icons.person_outline,
                controller: _name,
                validator: Validators.name,
              ),
              CustomTextField(
                label: 'Email',
                icon: Icons.email_outlined,
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              CustomTextField(
                label: 'Phone',
                icon: Icons.phone_outlined,
                controller: _phone,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
              ),
              CustomTextField(
                label: _isEdit
                    ? 'New password (leave blank to keep current)'
                    : 'Password',
                icon: Icons.lock_outline,
                controller: _password,
                obscure: true,
                validator: _isEdit
                    ? (v) {
                        if (v == null || v.isEmpty) return null;
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      }
                    : Validators.password,
              ),
              SwitchListTile(
                value: _isAdmin,
                onChanged: (v) => setState(() => _isAdmin = v),
                title: const Text('Administrator account'),
                subtitle: const Text(
                    'Admins can manage users, cities, attractions, and reviews'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_isEdit ? 'Save changes' : 'Create user'),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _StatPill(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text('$value',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
