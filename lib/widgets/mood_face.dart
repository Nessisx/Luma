import 'package:flutter/material.dart';

/// Vector expressions: independent of the phone's emoji font.
class MoodFace extends StatelessWidget {
  final int mood;
  final double size;
  const MoodFace({required this.mood, this.size = 64, super.key});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
      child: CustomPaint(
          size: Size.square(size), painter: _FacePainter(mood.clamp(0, 4))));
}

class _FacePainter extends CustomPainter {
  final int mood;
  const _FacePainter(this.mood);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final colors = [
      const Color(0xFFAFBFEA),
      const Color(0xFFB5CED6),
      const Color(0xFFEACD96),
      const Color(0xFFABD397),
      const Color(0xFF84C6A0)
    ];
    final color = colors[mood];
    canvas.drawOval(const Rect.fromLTWH(15, 85, 70, 10),
        Paint()..color = Colors.black.withValues(alpha: .08));
    canvas.drawCircle(
        const Offset(50, 46),
        42,
        Paint()
          ..shader = RadialGradient(center: const Alignment(-.4, -.6), colors: [
            Color.lerp(color, Colors.white, .5)!,
            color,
            Color.lerp(color, const Color(0xFF22523F), .15)!
          ]).createShader(const Rect.fromLTWH(8, 4, 84, 84)));
    canvas.drawOval(const Rect.fromLTWH(23, 13, 28, 10),
        Paint()..color = Colors.white.withValues(alpha: .23));
    final ink = Paint()
      ..color = const Color(0xFF23483C)
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final cheek = Paint()
      ..color = const Color(0xFFDA8280).withValues(alpha: .4);
    canvas.drawOval(const Rect.fromLTWH(19, 49, 16, 9), cheek);
    canvas.drawOval(const Rect.fromLTWH(65, 49, 16, 9), cheek);
    for (final x in [36.0, 64.0]) {
      if (mood == 4) {
        canvas.drawPath(
            Path()
              ..moveTo(x - 5, 42)
              ..quadraticBezierTo(x, 33, x + 5, 42),
            ink);
      } else {
        canvas.drawOval(
            Rect.fromCenter(center: Offset(x, 40), width: 5.5, height: 8),
            Paint()..color = ink.color);
        canvas.drawCircle(Offset(x - 1, 38), 1, Paint()..color = Colors.white);
      }
    }
    final mouth = Path()..moveTo(37, mood < 2 ? 65 : 59);
    if (mood < 2) {
      mouth.quadraticBezierTo(50, mood == 0 ? 48 : 55, 63, 65);
    } else if (mood == 2) {
      mouth.lineTo(63, 59);
    } else {
      mouth.quadraticBezierTo(50, mood == 4 ? 81 : 74, 63, 59);
    }
    canvas.drawPath(mouth, ink);
    if (mood == 0) {
      canvas.drawLine(const Offset(30, 33), const Offset(40, 29), ink);
      canvas.drawLine(const Offset(60, 29), const Offset(70, 33), ink);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FacePainter oldDelegate) => oldDelegate.mood != mood;
}
