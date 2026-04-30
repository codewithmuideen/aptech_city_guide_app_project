import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = false;

  AppUser? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    await StorageService.instance.init();
    _user = await AuthService.instance.currentUser();
    _loading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    final user = await AuthService.instance.login(email, password);
    _loading = false;
    if (user == null) {
      notifyListeners();
      return 'Invalid email or password';
    }
    _user = user;
    notifyListeners();
    return null;
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _loading = true;
    notifyListeners();
    final user = await AuthService.instance.register(
        name: name, email: email, password: password, phone: phone);
    _loading = false;
    if (user == null) {
      notifyListeners();
      return 'An account with this email already exists';
    }
    _user = user;
    notifyListeners();
    return null;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    return AuthService.instance.resetPassword(email, newPassword);
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> updateUser(AppUser updated) async {
    await AuthService.instance.updateUser(updated);
    _user = updated;
    notifyListeners();
  }

  Future<void> toggleFavorite(String attractionId) async {
    if (_user == null) return;
    if (_user!.favoriteAttractions.contains(attractionId)) {
      _user!.favoriteAttractions.remove(attractionId);
    } else {
      _user!.favoriteAttractions.add(attractionId);
    }
    await AuthService.instance.updateUser(_user!);
    notifyListeners();
  }
}
