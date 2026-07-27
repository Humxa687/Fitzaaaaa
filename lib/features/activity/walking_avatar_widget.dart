import 'dart:math' as math;
import 'package:flutter/material.dart';

class WalkingAvatarWidget extends StatefulWidget {
  final bool isWalking;
  final double size;

  const WalkingAvatarWidget({
    super.key,
    required this.isWalking,
    this.size = 110,
  });

  @override
  State<WalkingAvatarWidget> createState() => _WalkingAvatarWidgetState();
}

class _WalkingAvatarWidgetState extends State<WalkingAvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (widget.isWalking) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WalkingAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWalking != oldWidget.isWalking) {
      if (widget.isWalking) {
        _animController.repeat(reverse: true);
      } else {
        _animController.stop();
        _animController.animateTo(0.5, duration: const Duration(milliseconds: 150));
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final double progress = _animController.value;
        final double legAngle = widget.isWalking ? (math.sin(progress * math.pi * 2) * 0.4) : 0.0;
        final double bodyBob = widget.isWalking ? (math.sin(progress * math.pi * 2).abs() * 6.0) : 0.0;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _CharacterAvatarPainter(
              legAngle: legAngle,
              bodyBob: bodyBob,
              isWalking: widget.isWalking,
              primaryColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}

class _CharacterAvatarPainter extends CustomPainter {
  final double legAngle;
  final double bodyBob;
  final bool isWalking;
  final Color primaryColor;

  _CharacterAvatarPainter({
    required this.legAngle,
    required this.bodyBob,
    required this.isWalking,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2 + 10 - bodyBob;

    final Paint bodyPaint = Paint()..color = primaryColor;
    final Paint skinPaint = Paint()..color = const Color(0xFFFFD1B3);
    final Paint darkPaint = Paint()..color = const Color(0xFF1E293B);
    final Paint orangePaint = Paint()..color = const Color(0xFFF97316);
    final Paint linePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Shadow on Ground
    final Paint shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.15);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, size.height - 12),
        width: isWalking ? 45 + (legAngle * 10).abs() : 38,
        height: 10,
      ),
      shadowPaint,
    );

    // Left Leg
    canvas.save();
    canvas.translate(centerX - 8, centerY + 18);
    canvas.rotate(legAngle);
    canvas.drawLine(Offset.zero, const Offset(0, 22), linePaint);
    // Shoe
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-4, 20, 14, 7), const Radius.circular(3)),
      orangePaint,
    );
    canvas.restore();

    // Right Leg
    canvas.save();
    canvas.translate(centerX + 8, centerY + 18);
    canvas.rotate(-legAngle);
    canvas.drawLine(Offset.zero, const Offset(0, 22), linePaint);
    // Shoe
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-4, 20, 14, 7), const Radius.circular(3)),
      orangePaint,
    );
    canvas.restore();

    // Body Shirt
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, centerY + 6), width: 30, height: 26),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Left Arm
    canvas.save();
    canvas.translate(centerX - 16, centerY);
    canvas.rotate(-legAngle * 1.2);
    canvas.drawLine(Offset.zero, const Offset(-4, 16), linePaint);
    canvas.restore();

    // Right Arm
    canvas.save();
    canvas.translate(centerX + 16, centerY);
    canvas.rotate(legAngle * 1.2);
    canvas.drawLine(Offset.zero, const Offset(4, 16), linePaint);
    canvas.restore();

    // Head
    canvas.drawCircle(Offset(centerX, centerY - 14), 16, skinPaint);

    // Headband
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 17, centerY - 24, 34, 7),
        const Radius.circular(3),
      ),
      orangePaint,
    );

    // Eyes
    canvas.drawCircle(Offset(centerX - 5, centerY - 14), 2.2, darkPaint);
    canvas.drawCircle(Offset(centerX + 5, centerY - 14), 2.2, darkPaint);

    // Smile / Expression
    final Path mouthPath = Path();
    mouthPath.moveTo(centerX - 4, centerY - 8);
    mouthPath.quadraticBezierTo(centerX, centerY - 5, centerX + 4, centerY - 8);
    canvas.drawPath(mouthPath, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Walking Motion Sparkles
    if (isWalking) {
      final Paint sparklePaint = Paint()..color = const Color(0xFFF97316).withValues(alpha: 0.6);
      canvas.drawCircle(Offset(centerX - 24 - (bodyBob * 2), centerY + 10), 3, sparklePaint);
      canvas.drawCircle(Offset(centerX + 24 + (bodyBob * 2), centerY + 4), 2.5, sparklePaint);
    }

  }

  @override
  bool shouldRepaint(covariant _CharacterAvatarPainter oldDelegate) {
    return oldDelegate.legAngle != legAngle ||
        oldDelegate.bodyBob != bodyBob ||
        oldDelegate.isWalking != isWalking;
  }
}
