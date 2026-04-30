class AppConstants {
  static const String appName = 'City Guide';
  static const String appTagline = 'Discover your city, one place at a time';

  // Admin credentials (demo). In production, use secure backend auth.
  static const String adminEmail = 'admin@cityguide.com';
  static const String adminPassword = 'Admin@123';

  // Shared prefs keys
  static const String prefsCurrentUser = 'current_user_id';
  static const String prefsThemeMode = 'theme_mode';

  // Categories
  static const List<String> categories = [
    'All',
    'Attraction',
    'Restaurant',
    'Hotel',
    'Event',
  ];
}
