import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final String? base64Image;
  final double size;
  final bool showBorder;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.base64Image,
    this.size = 48,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    Widget inner;

    if (base64Image != null && base64Image!.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(base64Image!);
        inner = Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        inner = _initialsBackground(initials);
      }
    } else {
      inner = _initialsBackground(initials);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: Colors.white, width: 3)
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(child: inner),
    );
  }

  Widget _initialsBackground(String initials) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _initials(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
