import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'smart_image.dart';

/// Reusable image-source picker. Lets the user either:
///   - pick a file from their device gallery  (stored as a data URL), or
///   - paste a remote URL via the text field
///
/// Both end up in the same controller string used by City / Attraction
/// records, so the rest of the app keeps a single source-of-truth field.
class ImageSourcePicker extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final double previewHeight;

  const ImageSourcePicker({
    super.key,
    required this.controller,
    this.label = 'Image',
    this.previewHeight = 160,
  });

  @override
  State<ImageSourcePicker> createState() => _ImageSourcePickerState();
}

class _ImageSourcePickerState extends State<ImageSourcePicker> {
  bool _busy = false;

  Future<void> _pick() async {
    setState(() => _busy = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 85);
      if (picked == null) return;
      final bytes =
          kIsWeb ? await picked.readAsBytes() : await File(picked.path).readAsBytes();
      final mime = picked.mimeType ?? 'image/jpeg';
      final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
      widget.controller.text = dataUrl;
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not pick image: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _clear() {
    widget.controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(widget.label,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        InkWell(
          onTap: _busy ? null : _pick,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: widget.previewHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(hasValue ? 0.4 : 0.2),
                  width: 1.4,
                  style: BorderStyle.solid),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasValue
                ? Stack(fit: StackFit.expand, children: [
                    SmartImage(source: widget.controller.text),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Wrap(spacing: 8, children: [
                        _MiniButton(
                            icon: Icons.swap_horiz,
                            label: 'Change',
                            onTap: _busy ? null : _pick),
                        _MiniButton(
                            icon: Icons.delete_outline,
                            label: 'Remove',
                            onTap: _busy ? null : _clear,
                            danger: true),
                      ]),
                    ),
                  ])
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 38,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 6),
                        const Text('Tap to choose a photo from your device',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('JPG / PNG, up to 1600 px',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.controller,
          maxLines: 1,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: '...or paste an image URL',
            prefixIcon: Icon(Icons.link),
          ),
        ),
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  const _MiniButton(
      {required this.icon, required this.label, this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red.shade700 : Colors.black87;
    return Material(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ]),
        ),
      ),
    );
  }
}
