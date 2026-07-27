import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'workout_models.dart';
import '../../core/theme.dart';

class ExerciseAnimationWidget extends StatefulWidget {
  final ExerciseAnimationType animationType;
  final double height;
  final String exerciseName;

  const ExerciseAnimationWidget({
    super.key,
    required this.animationType,
    this.height = 220,
    this.exerciseName = "",
  });

  @override
  State<ExerciseAnimationWidget> createState() => _ExerciseAnimationWidgetState();
}

class _ExerciseAnimationWidgetState extends State<ExerciseAnimationWidget> {
  Flutter3DController controller = Flutter3DController();

  String _getModelPath() {
    switch (widget.animationType) {
      case ExerciseAnimationType.squat:
      case ExerciseAnimationType.lunge:
        return 'assets/models/Air Squat.glb';
      case ExerciseAnimationType.pushup:
      case ExerciseAnimationType.benchPress:
        return 'assets/models/Push Up.glb';
      case ExerciseAnimationType.plank:
      case ExerciseAnimationType.crunch:
        return 'assets/models/Plank.glb';
      default:
        // Fallback for missing models - using Squat as placeholder
        return 'assets/models/Air Squat.glb';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: FitzaTheme.energyOrange.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: FitzaTheme.energyOrange.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 2,
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background grid lines
          CustomPaint(
            size: Size(double.infinity, widget.height),
            painter: GridBackgroundPainter(),
          ),

          // 3D Model Viewer
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Flutter3DViewer(
              controller: controller,
              src: _getModelPath(),
              progressBarColor: FitzaTheme.energyOrange,
            ),
          ),

          // Live Animation Badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: FitzaTheme.energyOrange, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: FitzaTheme.energyOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "3D TRAINER",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 12,
            left: 12,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => controller.playAnimation(),
                  icon: const Icon(Icons.play_circle_fill, color: FitzaTheme.energyOrange, size: 32),
                ),
                IconButton(
                  onPressed: () => controller.pauseAnimation(),
                  icon: const Icon(Icons.pause_circle_filled, color: Colors.white70, size: 32),
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
