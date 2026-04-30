import 'package:flutter/material.dart';

/// Programmatic city-skyline-with-pin logo, rendered via CustomPainter
/// so the app has a consistent brand mark without external SVG dependencies.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showBackground;

  const AppLogo({super.key, this.size = 96, this.showBackground = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: LogoPainter(showBackground: showBackground)),
    );
  }
}

/// Public painter so tools (e.g. `tool/generate_icons.dart`) can reuse it
/// to export the brand mark to a PNG asset without going through a widget
/// render pipeline.
class LogoPainter extends CustomPainter {
  final bool showBackground;
  LogoPainter({this.showBackground = true});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 512;
    canvas.save();
    canvas.scale(scale);

    final rect = Rect.fromLTWH(0, 0, 512, 512);
    if (showBackground) {
      final bgPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
        ).createShader(rect);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(110)), bgPaint);

      // highlight
      final hi = Paint()..color = Colors.white.withOpacity(0.08);
      canvas.drawCircle(const Offset(140, 130), 120, hi);
    }

    // Buildings
    final building = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Color(0xFFE3F2FD)],
      ).createShader(Rect.fromLTWH(96, 220, 328, 200));

    final buildings = [
      [96.0, 300.0, 52.0, 120.0],
      [156.0, 250.0, 46.0, 170.0],
      [210.0, 220.0, 58.0, 200.0],
      [276.0, 260.0, 46.0, 160.0],
      [330.0, 230.0, 54.0, 190.0],
      [392.0, 290.0, 32.0, 130.0],
    ];
    for (final b in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(b[0], b[1], b[2], b[3]), const Radius.circular(6)),
        building,
      );
    }

    // Windows
    final windowPaint = Paint()..color = const Color(0xFF1565C0).withOpacity(0.45);
    final windows = [
      [108.0, 320.0], [126.0, 320.0], [108.0, 345.0], [126.0, 345.0],
      [166.0, 275.0], [184.0, 275.0], [166.0, 300.0], [184.0, 300.0],
      [222.0, 250.0], [240.0, 250.0], [222.0, 280.0], [240.0, 280.0],
      [222.0, 310.0], [240.0, 310.0],
      [286.0, 285.0], [302.0, 285.0],
      [342.0, 260.0], [360.0, 260.0], [342.0, 290.0], [360.0, 290.0],
    ];
    for (final w in windows) {
      canvas.drawRect(Rect.fromLTWH(w[0], w[1], 10, 14), windowPaint);
    }

    // Ground line
    final ground = Paint()..color = Colors.white.withOpacity(0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(72, 420, 368, 10), const Radius.circular(5)),
      ground,
    );

    // Pin
    final pinPath = Path()
      ..moveTo(256, 80)
      ..cubicTo(312, 80, 352, 122, 352, 176)
      ..cubicTo(352, 238, 280, 300, 258, 316)
      ..cubicTo(256, 318, 254, 318, 252, 316)
      ..cubicTo(232, 300, 160, 238, 160, 176)
      ..cubicTo(160, 122, 200, 80, 256, 80)
      ..close();

    final pinPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF7043), Color(0xFFE64A19)],
      ).createShader(const Rect.fromLTWH(160, 80, 192, 240));

    canvas.drawPath(pinPath, pinPaint);
    final pinStroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(pinPath, pinStroke);

    final dotOuter = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(256, 172), 34, dotOuter);
    final dotInner = Paint()..color = const Color(0xFFE64A19);
    canvas.drawCircle(const Offset(256, 172), 14, dotInner);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) =>
      oldDelegate.showBackground != showBackground;
}
