// ignore_for_file: avoid_print
//
// Icon generator
// ==============
//
// Renders the in-app [LogoPainter] to a 1024x1024 PNG and places it at
// assets/icons/app_logo.png. After running this script, run
//
//     dart run flutter_launcher_icons
//
// to regenerate the Android / iOS / Web / Windows launcher icons from
// that master PNG.
//
// Usage (one-shot):
//     flutter run -d windows --target=tool/generate_icons.dart
//     flutter run -d macos   --target=tool/generate_icons.dart
//     flutter run -d linux   --target=tool/generate_icons.dart
//
// The app window will briefly open, write the PNG, then exit.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:city_guide_app/widgets/app_logo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const size = 1024.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  LogoPainter().paint(canvas, const Size(size, size));

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) {
    stderr.writeln('Failed to encode PNG.');
    exit(1);
  }

  final out = File('assets/icons/app_logo.png');
  await out.parent.create(recursive: true);
  await out.writeAsBytes(bytes.buffer.asUint8List());
  print('Wrote ${out.path} (${out.lengthSync() ~/ 1024} KB)');

  // A non-zero exit would be printed as an error by the Flutter tool; we just
  // leave the window open for a moment so the user sees the success log.
  runApp(_DoneScreen(path: out.path));
}

class _DoneScreen extends StatelessWidget {
  final String path;
  const _DoneScreen({required this.path});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 72),
                const SizedBox(height: 12),
                const Text('Icon generated',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(path, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                const Text(
                  'Next: run  dart run flutter_launcher_icons  to export platform icons.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
