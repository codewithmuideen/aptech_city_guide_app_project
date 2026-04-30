import 'package:flutter/material.dart';

import '../models/city.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';
import 'profile_avatar.dart';

class GreetingHeader extends StatelessWidget {
  final AppUser? user;
  final City? city;
  final VoidCallback onChangeCity;
  final VoidCallback onOpenProfile;

  const GreetingHeader({
    super.key,
    required this.user,
    required this.city,
    required this.onChangeCity,
    required this.onOpenProfile,
  });

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String get _emoji {
    final h = DateTime.now().hour;
    if (h < 12) return '☀️';
    if (h < 18) return '🌤️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    final name = (user?.name.split(' ').first ?? 'there').trim();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 20),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$_greeting $_emoji',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            letterSpacing: 0.3)),
                    const SizedBox(height: 2),
                    Text('Hi, $name',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onOpenProfile,
                child: ProfileAvatar(
                  name: user?.name ?? '?',
                  base64Image: user?.profileImage,
                  size: 46,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onChangeCity,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.22)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      city == null
                          ? 'Pick a city'
                          : '${city!.name}, ${city!.country}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
