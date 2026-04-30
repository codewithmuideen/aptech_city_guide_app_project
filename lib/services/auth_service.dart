import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<AppUser?> login(String email, String password) async {
    final users = await StorageService.instance.getUsers();
    final hash = hashPassword(password);
    for (final u in users) {
      if (u.email.toLowerCase() == email.toLowerCase() && u.passwordHash == hash) {
        await StorageService.instance.setCurrentUserId(u.id);
        return u;
      }
    }
    return null;
  }

  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final users = await StorageService.instance.getUsers();
    if (users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      return null;
    }
    final user = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      passwordHash: hashPassword(password),
    );
    users.add(user);
    await StorageService.instance.saveUsers(users);
    await StorageService.instance.setCurrentUserId(user.id);
    return user;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    final users = await StorageService.instance.getUsers();
    final idx = users.indexWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    if (idx == -1) return false;
    users[idx].passwordHash = hashPassword(newPassword);
    await StorageService.instance.saveUsers(users);
    return true;
  }

  Future<AppUser?> currentUser() async {
    final id = await StorageService.instance.getCurrentUserId();
    if (id == null) return null;
    final users = await StorageService.instance.getUsers();
    for (final u in users) {
      if (u.id == id) return u;
    }
    return null;
  }

  Future<void> logout() => StorageService.instance.setCurrentUserId(null);

  Future<void> updateUser(AppUser updated) async {
    final users = await StorageService.instance.getUsers();
    final idx = users.indexWhere((u) => u.id == updated.id);
    if (idx != -1) {
      users[idx] = updated;
      await StorageService.instance.saveUsers(users);
    }
  }
}
