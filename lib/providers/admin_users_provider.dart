import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AdminUsersProvider extends ChangeNotifier {
  List<AppUser> _users = [];
  List<AppUser> get users => _users;

  Future<void> load() async {
    _users = await StorageService.instance.getUsers();
    notifyListeners();
  }

  int get adminCount => _users.where((u) => u.isAdmin).length;
  int get regularCount => _users.where((u) => !u.isAdmin).length;

  Future<void> deleteUser(String id) async {
    _users.removeWhere((u) => u.id == id);
    await StorageService.instance.saveUsers(_users);
    notifyListeners();
  }

  Future<void> toggleAdmin(String id) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx == -1) return;
    _users[idx].isAdmin = !_users[idx].isAdmin;
    await StorageService.instance.saveUsers(_users);
    notifyListeners();
  }

  /// Creates a new user (admin or regular). Returns null on success,
  /// or an error message for duplicate email.
  Future<String?> createUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    bool isAdmin = false,
  }) async {
    if (_users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      return 'An account with this email already exists';
    }
    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      passwordHash: AuthService.instance.hashPassword(password),
      isAdmin: isAdmin,
    );
    _users.add(user);
    await StorageService.instance.saveUsers(_users);
    notifyListeners();
    return null;
  }

  /// Updates an existing user's name/email/phone/admin flag. If [newPassword]
  /// is provided, resets their password.
  Future<String?> updateUser({
    required String id,
    required String name,
    required String email,
    required String phone,
    required bool isAdmin,
    String? newPassword,
  }) async {
    final idx = _users.indexWhere((u) => u.id == id);
    if (idx == -1) return 'User not found';
    final conflict = _users.any((u) =>
        u.id != id && u.email.toLowerCase() == email.toLowerCase());
    if (conflict) return 'Email already used by another account';
    final u = _users[idx];
    u.name = name;
    u.email = email;
    u.phone = phone;
    u.isAdmin = isAdmin;
    if (newPassword != null && newPassword.isNotEmpty) {
      u.passwordHash = AuthService.instance.hashPassword(newPassword);
    }
    await StorageService.instance.saveUsers(_users);
    notifyListeners();
    return null;
  }
}
