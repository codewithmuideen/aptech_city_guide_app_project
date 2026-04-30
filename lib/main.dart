import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/admin_users_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/city_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CityGuideApp());
}

class CityGuideApp extends StatelessWidget {
  const CityGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..load()),
        ChangeNotifierProvider(create: (_) => CityProvider()..load()),
        ChangeNotifierProvider(create: (_) => AdminUsersProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'City Guide',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.mode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
