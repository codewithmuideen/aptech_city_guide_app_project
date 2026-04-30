import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/city.dart';
import '../models/attraction.dart';
import '../models/review.dart';
import '../data/sample_data.dart';

/// A simple JSON-backed storage layer over SharedPreferences.
/// Keeps the project offline-friendly and zero-config for evaluators.
class StorageService {
  static const _kUsers = 'users';
  static const _kCities = 'cities';
  static const _kAttractions = 'attractions';
  static const _kReviews = 'reviews';

  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _sp async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> init() async {
    // Idempotent / additive seeding: never overwrites existing records.
    // Safe to re-run on every launch; no user data ever gets wiped.
    await _mergeSeed(_kCities,
        SampleData.cities.map((c) => c.toJson()).toList());
    await _mergeSeed(_kAttractions,
        SampleData.attractions.map((a) => a.toJson()).toList());
    await _ensureAdminUser();
    final reviews = await _readList(_kReviews);
    if (reviews.isEmpty) await _writeList(_kReviews, []);
  }

  /// Writes [seed] entries into [key] only if a record with the same `id`
  /// is not already present. Existing user-modified data is preserved.
  Future<void> _mergeSeed(String key, List<Map<String, dynamic>> seed) async {
    final existing = await _readList(key);
    final existingIds = existing.map((e) => e['id']).toSet();
    final merged = [
      ...existing,
      for (final s in seed)
        if (!existingIds.contains(s['id'])) s,
    ];
    await _writeList(key, merged);
  }

  /// Ensures the seeded admin account exists. Never overwrites other users.
  Future<void> _ensureAdminUser() async {
    final users = await _readList(_kUsers);
    final admin = SampleData.adminUser.toJson();
    final hasAdmin = users.any((u) => u['id'] == admin['id']);
    if (!hasAdmin) {
      users.add(admin);
      await _writeList(_kUsers, users);
    }
  }

  Future<List<Map<String, dynamic>>> _readList(String key) async {
    final sp = await _sp;
    final raw = sp.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> items) async {
    final sp = await _sp;
    await sp.setString(key, jsonEncode(items));
  }

  // Users
  Future<List<AppUser>> getUsers() async {
    final raw = await _readList(_kUsers);
    return raw.map(AppUser.fromJson).toList();
  }

  Future<void> saveUsers(List<AppUser> users) =>
      _writeList(_kUsers, users.map((u) => u.toJson()).toList());

  // Cities
  Future<List<City>> getCities() async {
    final raw = await _readList(_kCities);
    return raw.map(City.fromJson).toList();
  }

  Future<void> saveCities(List<City> cities) =>
      _writeList(_kCities, cities.map((c) => c.toJson()).toList());

  // Attractions
  Future<List<Attraction>> getAttractions() async {
    final raw = await _readList(_kAttractions);
    return raw.map(Attraction.fromJson).toList();
  }

  Future<void> saveAttractions(List<Attraction> items) =>
      _writeList(_kAttractions, items.map((a) => a.toJson()).toList());

  // Reviews
  Future<List<Review>> getReviews() async {
    final raw = await _readList(_kReviews);
    return raw.map(Review.fromJson).toList();
  }

  Future<void> saveReviews(List<Review> items) =>
      _writeList(_kReviews, items.map((r) => r.toJson()).toList());

  Future<void> setCurrentUserId(String? id) async {
    final sp = await _sp;
    if (id == null) {
      await sp.remove('current_user_id');
    } else {
      await sp.setString('current_user_id', id);
    }
  }

  Future<String?> getCurrentUserId() async =>
      (await _sp).getString('current_user_id');
}
