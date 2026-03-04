import 'package:flutter/material.dart';

class AnimatedLiquidBackground extends StatefulWidget {
  const AnimatedLiquidBackground({super.key});

  @override
  State<AnimatedLiquidBackground> createState() => _AnimatedLiquidBackgroundState();
}

class _AnimatedLiquidBackgroundState extends State<AnimatedLiquidBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _LiquidPainter(_controller.value),
          child: Container(),
        );
      },
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final double t;
  _LiquidPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFff6fd8), Color(0xFF3813c2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF42e695), Color(0xFF3bb2b8)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.plus;

    final path1 = Path();
    final path2 = Path();

    final h = size.height;
    final w = size.width;

    path1.moveTo(0, h * (0.6 + 0.1 * t));
    path1.cubicTo(
      w * 0.25,
      h * (0.5 + 0.15 * (1 - t)),
      w * 0.75,
      h * (0.7 + 0.1 * t),
      w,
      h * (0.6 + 0.1 * (1 - t)),
    );
    path1.lineTo(w, h);
    path1.lineTo(0, h);
    path1.close();

    path2.moveTo(0, h * (0.3 + 0.1 * (1 - t)));
    path2.cubicTo(
      w * 0.2,
      h * (0.2 + 0.1 * t),
      w * 0.8,
      h * (0.4 + 0.1 * (1 - t)),
      w,
      h * (0.3 + 0.1 * t),
    );
    path2.lineTo(w, h);
    path2.lineTo(0, h);
    path2.close();

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF050816));
    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) => oldDelegate.t != t;
}
