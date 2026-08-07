import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'workout_models.dart';
import '../../core/theme.dart';
enum ExerciseState { idle, active, resting }

class ExerciseAnimationWidget extends StatefulWidget {
  final ExerciseAnimationType animationType;
  final double height;
  final String exerciseName;
  final bool autoPlay;
  final ExerciseState state;

  const ExerciseAnimationWidget({
    super.key,
    required this.animationType,
    this.height = 220,
    this.exerciseName = "",
    this.autoPlay = false,
    this.state = ExerciseState.active,
  });

  @override
  State<ExerciseAnimationWidget> createState() => _ExerciseAnimationWidgetState();
}

class _ExerciseAnimationWidgetState extends State<ExerciseAnimationWidget> {
  Flutter3DController controller = Flutter3DController();

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          controller.playAnimation();
        }
      });
    }
  }

  String _getModelPath() {
    switch (widget.animationType) {
      case ExerciseAnimationType.pushup:
      case ExerciseAnimationType.benchPress:
        if (widget.state == ExerciseState.idle) return 'assets/models/Idle To Push Up.glb';
        if (widget.state == ExerciseState.resting) return 'assets/models/Push Up To Idle.glb';
        return 'assets/models/Push Up.glb';
      default:
        // Safe fallback to valid 3D asset
        return 'assets/models/Push Up.glb';
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
          color: FitzaTheme.primaryDark.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background stage
            CustomPaint(
              size: Size(double.infinity, widget.height),
              painter: StageBackgroundPainter(),
            ),

            // 3D Model Viewer
            Flutter3DViewer(
              controller: controller,
              src: _getModelPath(),
              progressBarColor: FitzaTheme.primaryDark,
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
                  border: Border.all(color: FitzaTheme.primaryDark, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: FitzaTheme.primaryDark,
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => controller.playAnimation(),
                      icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                    IconButton(
                      onPressed: () => controller.pauseAnimation(),
                      icon: const Icon(Icons.pause_circle_filled, color: Colors.white70, size: 28),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class StageBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Solid dark blue background matching the reference
    final bgPaint = Paint()..color = const Color(0xFF1B2A7A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Floor oval matching the reference
    final floorPaint = Paint()..color = const Color(0xFF334BBD);
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.9), // Positioned near bottom
      width: size.width * 1.2,
      height: size.height * 0.7, // Flat oval
    );
    canvas.drawOval(ovalRect, floorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
