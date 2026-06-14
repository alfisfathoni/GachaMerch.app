import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class CyberLoading extends StatefulWidget {
  final String label;
  const CyberLoading({super.key, this.label = 'CONNECTING TO SOL-3...'});

  @override
  State<CyberLoading> createState() => _CyberLoadingState();
}

class _CyberLoadingState extends State<CyberLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _rotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _pulse = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.2).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.8).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotation.value,
              child: Transform.scale(
                scale: _pulse.value,
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: CustomPaint(
                    painter: _TacetMarkPainter(),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            return Opacity(
              opacity: (0.4 + (_pulse.value - 0.8) * 1.5).clamp(0.2, 1.0),
              child: Text(
                widget.label,
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: AppTheme.primaryColor,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TacetMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final paintOuter = Paint()
      ..color = AppTheme.primaryColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paintInner = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw outer ring segments
    for (int i = 0; i < 4; i++) {
      final startAngle = i * (pi / 2) + 0.2;
      final sweepAngle = (pi / 2) - 0.4;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paintOuter,
      );
    }

    // Draw inner ring segments
    for (int i = 0; i < 3; i++) {
      final startAngle = i * (2 * pi / 3) - 0.2;
      final sweepAngle = (2 * pi / 3) - 0.6;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 6),
        startAngle,
        sweepAngle,
        false,
        paintInner,
      );
    }

    // Draw glowing center dot
    final paintCenter = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, paintCenter);

    // Draw soundwave/tacet crescent spikes
    final paintSpike = Paint()
      ..color = AppTheme.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 12; i++) {
      final angle = i * (2 * pi / 12);
      final startOffset = Offset(
        center.dx + (radius - 12) * cos(angle),
        center.dy + (radius - 12) * sin(angle),
      );
      final endOffset = Offset(
        center.dx + (radius + 2) * cos(angle),
        center.dy + (radius + 2) * sin(angle),
      );
      if (i % 2 == 0) {
        canvas.drawLine(startOffset, endOffset, paintSpike);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
