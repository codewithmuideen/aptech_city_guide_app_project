import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders an image source that may be:
///  - a remote URL  (https://...)
///  - a data URL    (data:image/png;base64,...)
///  - empty / null  (renders a soft placeholder)
///
/// Used everywhere we display city / attraction artwork so the UI works
/// whether the admin pasted a URL or picked a file from their device.
class SmartImage extends StatelessWidget {
  final String? source;
  final BoxFit fit;
  final double? width;
  final double? height;

  const SmartImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final s = source?.trim() ?? '';
    if (s.isEmpty) return _placeholder();

    if (s.startsWith('data:image')) {
      try {
        final base64Part = s.split(',').last;
        final Uint8List bytes = base64Decode(base64Part);
        return Image.memory(bytes,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => _placeholder());
      } catch (_) {
        return _placeholder();
      }
    }

    return CachedNetworkImage(
      imageUrl: s,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, __) => Container(color: Colors.grey.shade200),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: const Center(
          child: Icon(Icons.image_outlined, color: Colors.grey, size: 36)),
    );
  }
}
