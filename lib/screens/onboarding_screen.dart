import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';

const _kOnboardingSeenKey = 'onboarding_seen_v1';

class OnboardingScreen extends StatefulWidget {
  /// Builder for the screen to navigate to when onboarding is done.
  /// Resolved *inside* this widget's context so navigation doesn't run
  /// against the splash screen's disposed element.
  final WidgetBuilder nextBuilder;
  const OnboardingScreen({super.key, required this.nextBuilder});

  /// Returns true when the onboarding has already been shown at least once.
  static Future<bool> hasBeenSeen() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kOnboardingSeenKey) ?? false;
  }

  static Future<void> markSeen() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kOnboardingSeenKey, true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const <_OnboardingPage>[
    _OnboardingPage(
      icon: Icons.explore,
      title: 'Discover Your City',
      body:
          'Find hidden gems, popular attractions and local favorites - all in one place.',
    ),
    _OnboardingPage(
      icon: Icons.restaurant_menu,
      title: 'Eat, Stay, Explore',
      body:
          'From cozy cafes to five-star hotels, browse restaurants, hotels and events with rich details and reviews.',
    ),
    _OnboardingPage(
      icon: Icons.rate_review,
      title: 'Share Your Experience',
      body:
          'Rate places you love, write reviews, and help fellow travelers find the best spots in town.',
    ),
  ];

  Future<void> _finish() async {
    await OnboardingScreen.markSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (ctx, a, __) => FadeTransition(
          opacity: a,
          child: widget.nextBuilder(ctx),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text('Skip',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              const AppLogo(size: 96, showBackground: false),
              const SizedBox(height: 18),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _pages[i].build(context),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: active ? 24 : 8,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    if (!isLast)
                      TextButton(
                        onPressed: _finish,
                        child: const Text('Skip',
                            style: TextStyle(color: Colors.white70)),
                      ),
                    const Spacer(),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryDark,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 14),
                      ),
                      onPressed: () {
                        if (isLast) {
                          _finish();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                      label: Text(isLast ? 'Get Started' : 'Next'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardingPage(
      {required this.icon, required this.title, required this.body});

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 76, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 14),
          Text(body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}
