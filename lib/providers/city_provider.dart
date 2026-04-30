import 'package:flutter/material.dart';

import '../models/city.dart';
import '../models/attraction.dart';
import '../models/review.dart';
import '../services/storage_service.dart';

class CityProvider extends ChangeNotifier {
  List<City> _cities = [];
  List<Attraction> _attractions = [];
  List<Review> _reviews = [];

  String? _selectedCityId;

  List<City> get cities => _cities;
  List<Attraction> get attractions => _attractions;
  List<Review> get reviews => _reviews;
  String? get selectedCityId => _selectedCityId;

  City? get selectedCity =>
      _selectedCityId == null ? null : _cities.firstWhere(
          (c) => c.id == _selectedCityId,
          orElse: () => _cities.first);

  List<Attraction> get attractionsInSelectedCity =>
      _selectedCityId == null
          ? _attractions
          : _attractions.where((a) => a.cityId == _selectedCityId).toList();

  Future<void> load() async {
    await StorageService.instance.init();
    _cities = await StorageService.instance.getCities();
    _attractions = await StorageService.instance.getAttractions();
    _reviews = await StorageService.instance.getReviews();
    notifyListeners();
  }

  void selectCity(String id) {
    _selectedCityId = id;
    notifyListeners();
  }

  double averageRating(String attractionId) {
    final list = _reviews.where((r) => r.attractionId == attractionId).toList();
    if (list.isEmpty) return 0;
    final sum = list.fold<double>(0, (s, r) => s + r.rating);
    return sum / list.length;
  }

  List<Review> reviewsFor(String attractionId) =>
      _reviews.where((r) => r.attractionId == attractionId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Attraction> search(String query, {AttractionCategory? category}) {
    final q = query.trim().toLowerCase();
    return attractionsInSelectedCity.where((a) {
      final matchesQuery = q.isEmpty ||
          a.name.toLowerCase().contains(q) ||
          a.description.toLowerCase().contains(q) ||
          a.address.toLowerCase().contains(q);
      final matchesCategory = category == null || a.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  List<Attraction> filterSort({
    AttractionCategory? category,
    String sortBy = 'rating', // rating | name
  }) {
    var list = category == null
        ? attractionsInSelectedCity
        : attractionsInSelectedCity.where((a) => a.category == category).toList();
    list = List.of(list);
    if (sortBy == 'rating') {
      list.sort((a, b) => averageRating(b.id).compareTo(averageRating(a.id)));
    } else {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  // Admin CRUD
  Future<void> addCity(City c) async {
    _cities.add(c);
    await StorageService.instance.saveCities(_cities);
    notifyListeners();
  }

  Future<void> updateCity(City c) async {
    final idx = _cities.indexWhere((e) => e.id == c.id);
    if (idx != -1) {
      _cities[idx] = c;
      await StorageService.instance.saveCities(_cities);
      notifyListeners();
    }
  }

  Future<void> deleteCity(String id) async {
    _cities.removeWhere((c) => c.id == id);
    _attractions.removeWhere((a) => a.cityId == id);
    await StorageService.instance.saveCities(_cities);
    await StorageService.instance.saveAttractions(_attractions);
    notifyListeners();
  }

  Future<void> addAttraction(Attraction a) async {
    _attractions.add(a);
    await StorageService.instance.saveAttractions(_attractions);
    notifyListeners();
  }

  Future<void> updateAttraction(Attraction a) async {
    final idx = _attractions.indexWhere((e) => e.id == a.id);
    if (idx != -1) {
      _attractions[idx] = a;
      await StorageService.instance.saveAttractions(_attractions);
      notifyListeners();
    }
  }

  Future<void> deleteAttraction(String id) async {
    _attractions.removeWhere((a) => a.id == id);
    _reviews.removeWhere((r) => r.attractionId == id);
    await StorageService.instance.saveAttractions(_attractions);
    await StorageService.instance.saveReviews(_reviews);
    notifyListeners();
  }

  Future<void> addReview(Review r) async {
    _reviews.add(r);
    await StorageService.instance.saveReviews(_reviews);
    notifyListeners();
  }

  Future<void> toggleLikeReview(String reviewId, String userId) async {
    final idx = _reviews.indexWhere((r) => r.id == reviewId);
    if (idx == -1) return;
    final r = _reviews[idx];
    if (r.likedBy.contains(userId)) {
      r.likedBy.remove(userId);
    } else {
      r.likedBy.add(userId);
    }
    await StorageService.instance.saveReviews(_reviews);
    notifyListeners();
  }

  Future<void> deleteReview(String reviewId) async {
    _reviews.removeWhere((r) => r.id == reviewId);
    await StorageService.instance.saveReviews(_reviews);
    notifyListeners();
  }
}
