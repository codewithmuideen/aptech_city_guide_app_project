import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/attraction.dart';
import '../../models/review.dart';
import '../../providers/auth_provider.dart';
import '../../providers/city_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/review_tile.dart';

class AttractionDetailScreen extends StatelessWidget {
  final Attraction attraction;

  const AttractionDetailScreen({super.key, required this.attraction});

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _directions() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${attraction.latitude},${attraction.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openReviewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ReviewSheet(attraction: attraction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final city = context.watch<CityProvider>();
    final reviews = city.reviewsFor(attraction.id);
    final avg = city.averageRating(attraction.id);
    final favorite =
        auth.user?.favoriteAttractions.contains(attraction.id) ?? false;
    final gallery = [attraction.imageUrl, ...attraction.gallery];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 300,
            backgroundColor: AppTheme.primaryDark,
            leading: const BackButton(color: Colors.white),
            actions: [
              _GlassIconButton(
                icon: favorite ? Icons.favorite : Icons.favorite_border,
                color: favorite ? Colors.red.shade300 : Colors.white,
                onTap: () {
                  HapticFeedback.lightImpact();
                  final wasFav = favorite;
                  context.read<AuthProvider>().toggleFavorite(attraction.id);
                  if (!wasFav && auth.user != null) {
                    NotificationService.instance.show(
                      context,
                      title: 'Added to favorites',
                      body:
                          '${attraction.name} saved to your Favorites tab.',
                      icon: Icons.favorite,
                      forUser: auth.user,
                    );
                  }
                },
              ),
              _GlassIconButton(
                icon: Icons.share_outlined,
                color: Colors.white,
                onTap: () {
                  final text =
                      '${attraction.name} - ${attraction.address}\n${attraction.website}';
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')));
                },
              ),
              const SizedBox(width: 6),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(fit: StackFit.expand, children: [
                gallery.length == 1
                    ? Hero(
                        tag: 'attraction-${attraction.id}',
                        child: CachedNetworkImage(
                            imageUrl: gallery.first, fit: BoxFit.cover),
                      )
                    : CarouselSlider(
                        items: gallery
                            .map((url) => CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ))
                            .toList(),
                        options: CarouselOptions(
                          autoPlay: true,
                          viewportFraction: 1,
                          height: 300,
                        ),
                      ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0, 0.5, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(attraction.category.label,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                      const SizedBox(height: 8),
                      Text(attraction.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black54, blurRadius: 6)
                              ])),
                      const SizedBox(height: 4),
                      Row(children: [
                        RatingBarIndicator(
                          rating: avg,
                          itemCount: 5,
                          itemSize: 16,
                          itemBuilder: (_, __) =>
                              const Icon(Icons.star, color: Colors.amber),
                        ),
                        const SizedBox(width: 6),
                        Text('${avg.toStringAsFixed(1)}  (${reviews.length} reviews)',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13)),
                      ]),
                    ],
                  ),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -18),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Column(
                  children: [
                    _QuickActions(
                      onDirections: _directions,
                      onCall: attraction.phone.isEmpty
                          ? null
                          : () => _openUrl('tel:${attraction.phone}'),
                      onWeb: attraction.website.isEmpty
                          ? null
                          : () => _openUrl(attraction.website),
                      onReview: () => _openReviewSheet(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('About',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(attraction.description,
                              style: const TextStyle(
                                  fontSize: 15, height: 1.5)),
                          const SizedBox(height: 20),
                          const Text('Info',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _InfoTile(
                              icon: Icons.place_outlined,
                              label: 'Address',
                              value: attraction.address),
                          if (attraction.phone.isNotEmpty)
                            _InfoTile(
                                icon: Icons.phone_outlined,
                                label: 'Phone',
                                value: attraction.phone,
                                onTap: () => _openUrl('tel:${attraction.phone}')),
                          if (attraction.openingHours.isNotEmpty)
                            _InfoTile(
                                icon: Icons.access_time_outlined,
                                label: 'Hours',
                                value: attraction.openingHours),
                          if (attraction.website.isNotEmpty)
                            _InfoTile(
                                icon: Icons.language_outlined,
                                label: 'Website',
                                value: attraction.website,
                                onTap: () => _openUrl(attraction.website)),
                          const SizedBox(height: 20),
                          Row(children: [
                            Text('Reviews (${reviews.length})',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => _openReviewSheet(context),
                              icon: const Icon(Icons.edit_note),
                              label: const Text('Write a review'),
                            ),
                          ]),
                          if (reviews.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: EmptyState(
                                icon: Icons.rate_review_outlined,
                                title: 'No reviews yet',
                                message:
                                    'Be the first to share your experience.',
                              ),
                            ),
                          ...reviews.map((r) => ReviewTile(
                                review: r,
                                likedByMe: auth.user == null
                                    ? false
                                    : r.likedBy.contains(auth.user!.id),
                                onLike: () {
                                  if (auth.user == null) return;
                                  HapticFeedback.lightImpact();
                                  context
                                      .read<CityProvider>()
                                      .toggleLikeReview(r.id, auth.user!.id);
                                },
                              )),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Material(
        color: Colors.black.withOpacity(0.25),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onDirections;
  final VoidCallback? onCall;
  final VoidCallback? onWeb;
  final VoidCallback onReview;

  const _QuickActions({
    required this.onDirections,
    required this.onCall,
    required this.onWeb,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x22000000),
              blurRadius: 18,
              offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
              child: _QuickAction(
                  icon: Icons.directions,
                  label: 'Route',
                  color: Colors.blue,
                  onTap: onDirections)),
          Expanded(
              child: _QuickAction(
                  icon: Icons.phone,
                  label: 'Call',
                  color: Colors.green,
                  onTap: onCall)),
          Expanded(
              child: _QuickAction(
                  icon: Icons.language,
                  label: 'Website',
                  color: Colors.purple,
                  onTap: onWeb)),
          Expanded(
              child: _QuickAction(
                  icon: Icons.rate_review_outlined,
                  label: 'Review',
                  color: AppTheme.accent,
                  onTap: onReview)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: disabled
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      child: Opacity(
        opacity: disabled ? 0.4 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryDark, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: onTap != null ? AppTheme.primary : null,
                        decoration: onTap != null
                            ? TextDecoration.underline
                            : null,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  final Attraction attraction;
  const _ReviewSheet({required this.attraction});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  final _controller = TextEditingController();
  double _rating = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _ratingLabel {
    if (_rating >= 4.5) return 'Loved it';
    if (_rating >= 3.5) return 'Pretty good';
    if (_rating >= 2.5) return 'It was okay';
    if (_rating >= 1.5) return 'Disappointing';
    return 'Awful';
  }

  Future<void> _submit() async {
    final user = context.read<AuthProvider>().user;
    if (user == null || _controller.text.trim().isEmpty) return;
    await context.read<CityProvider>().addReview(Review(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          attractionId: widget.attraction.id,
          userId: user.id,
          userName: user.name,
          rating: _rating,
          comment: _controller.text.trim(),
          createdAt: DateTime.now(),
        ));
    if (!mounted) return;
    Navigator.pop(context);
    NotificationService.instance.show(
      context,
      title: 'Review posted',
      body: 'Thanks for sharing your experience at ${widget.attraction.name}.',
      icon: Icons.reviews_outlined,
      forUser: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Text('Review ${widget.attraction.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Text('How was it?',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 38,
            unratedColor: Colors.grey.shade300,
            itemBuilder: (_, __) =>
                const Icon(Icons.star_rounded, color: Colors.amber),
            onRatingUpdate: (v) {
              HapticFeedback.selectionClick();
              setState(() => _rating = v);
            },
          ),
          const SizedBox(height: 6),
          Text(_ratingLabel,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Share your experience...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send),
                label: const Text('Post review'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
