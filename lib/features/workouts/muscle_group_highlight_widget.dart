import 'package:flutter/material.dart';
import '../../core/theme.dart';

class MuscleGroupHighlightWidget extends StatelessWidget {
  final String targetMuscle;
  final double height;

  const MuscleGroupHighlightWidget({
    super.key,
    required this.targetMuscle,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // Muscle Highlight Vector Silhouette
          Container(
            width: 90,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: BodyMuscleHighlightPainter(
                targetMuscle: targetMuscle,
                highlightColor: FitzaTheme.energyOrange,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Muscle Target Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.my_location_rounded, color: FitzaTheme.energyOrange, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "TARGET MUSCLE GROUP",
                        style: TextStyle(
                          color: FitzaTheme.energyOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  targetMuscle.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getMuscleFocusDescription(targetMuscle),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMuscleFocusDescription(String muscle) {
    switch (muscle.toLowerCase()) {
      case 'chest':
        return 'Pectoralis major & minor upper chest activation';
      case 'biceps':
        return 'Biceps brachii short & long head peak contraction';
      case 'quadriceps':
        return 'Rectus femoris & vastus lateralis leg power';
      case 'deltoids':
        return 'Anterior, lateral & posterior shoulder cap';
      case 'abs':
        return 'Rectus abdominis & transverse abdominal core stability';
      case 'lats':
        return 'Latissimus dorsi back width & V-taper frame';
      case 'hamstrings':
        return 'Biceps femoris & gluteal posterior chain strength';
      default:
        return 'Primary muscle contraction target zone';
    }
  }
}

class BodyMuscleHighlightPainter extends CustomPainter {
  final String targetMuscle;
  final Color highlightColor;

  BodyMuscleHighlightPainter({
    required this.targetMuscle,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final bodyPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = highlightColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Head
    canvas.drawCircle(Offset(cx, cy - 40), 10, bodyPaint);

    // Torso Frame
    canvas.drawLine(Offset(cx, cy - 30), Offset(cx, cy + 15), bodyPaint);
    canvas.drawLine(Offset(cx - 20, cy - 25), Offset(cx + 20, cy - 25), bodyPaint);

    // Legs Frame
    canvas.drawLine(Offset(cx, cy + 15), Offset(cx - 15, cy + 45), bodyPaint);
    canvas.drawLine(Offset(cx, cy + 15), Offset(cx + 15, cy + 45), bodyPaint);

    // Highlight Specific Target Muscle Zone
    final m = targetMuscle.toLowerCase();

    if (m.contains('chest')) {
      canvas.drawCircle(Offset(cx - 8, cy - 18), 7, glowPaint);
      canvas.drawCircle(Offset(cx + 8, cy - 18), 7, glowPaint);
      canvas.drawCircle(Offset(cx - 8, cy - 18), 6, highlightPaint);
      canvas.drawCircle(Offset(cx + 8, cy - 18), 6, highlightPaint);
    } else if (m.contains('bicep') || m.contains('arm')) {
      canvas.drawCircle(Offset(cx - 22, cy - 16), 6, glowPaint);
      canvas.drawCircle(Offset(cx + 22, cy - 16), 6, glowPaint);
      canvas.drawCircle(Offset(cx - 22, cy - 16), 5, highlightPaint);
      canvas.drawCircle(Offset(cx + 22, cy - 16), 5, highlightPaint);
    } else if (m.contains('quad') || m.contains('leg')) {
      canvas.drawRect(Rect.fromLTWH(cx - 14, cy + 18, 10, 18), glowPaint);
      canvas.drawRect(Rect.fromLTWH(cx + 4, cy + 18, 10, 18), glowPaint);
      canvas.drawRect(Rect.fromLTWH(cx - 14, cy + 18, 10, 18), highlightPaint);
      canvas.drawRect(Rect.fromLTWH(cx + 4, cy + 18, 10, 18), highlightPaint);
    } else if (m.contains('abs') || m.contains('core')) {
      canvas.drawRRect(RRect.fromLTRBR(cx - 8, cy - 8, cx + 8, cy + 10, const Radius.circular(4)), glowPaint);
      canvas.drawRRect(RRect.fromLTRBR(cx - 8, cy - 8, cx + 8, cy + 10, const Radius.circular(4)), highlightPaint);
    } else if (m.contains('deltoid') || m.contains('shoulder')) {
      canvas.drawCircle(Offset(cx - 18, cy - 25), 6, glowPaint);
      canvas.drawCircle(Offset(cx + 18, cy - 25), 6, glowPaint);
      canvas.drawCircle(Offset(cx - 18, cy - 25), 5, highlightPaint);
      canvas.drawCircle(Offset(cx + 18, cy - 25), 5, highlightPaint);
    } else {
      // Default Lats / Back
      canvas.drawCircle(Offset(cx, cy - 10), 10, glowPaint);
      canvas.drawCircle(Offset(cx, cy - 10), 8, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
