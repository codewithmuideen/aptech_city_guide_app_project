import 'package:flutter/material.dart';

import '../models/user.dart';

/// In-app toast-style notification service.
/// Respects the per-user "notifications enabled" preference.
///
/// We deliberately avoid `flutter_local_notifications` to keep the app
/// plugin-free on web and desktop; real push notifications can be added
/// later by swapping the [show] implementation.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  OverlayEntry? _entry;

  void show(
    BuildContext context, {
    required String title,
    String? body,
    IconData icon = Icons.notifications_outlined,
    AppUser? forUser,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (forUser != null && !forUser.notificationsEnabled) return;

    final overlay = Overlay.of(context, rootOverlay: true);
    _entry?.remove();
    final entry = OverlayEntry(
      builder: (_) => _NotificationBanner(
        title: title,
        body: body,
        icon: icon,
        onDone: () {
          _entry?.remove();
          _entry = null;
        },
        duration: duration,
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }
}

class _NotificationBanner extends StatefulWidget {
  final String title;
  final String? body;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDone;

  const _NotificationBanner({
    required this.title,
    this.body,
    required this.icon,
    required this.duration,
    required this.onDone,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _slide = Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 12,
      right: 12,
      child: SafeArea(
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                          if (widget.body != null)
                            Text(widget.body!,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.close, color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
