import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/widgets/soft_card.dart';
import 'workout_models.dart';
import 'exercise_animation_widget.dart';
import 'muscle_group_highlight_widget.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late List<bool> _completedSets;
  Timer? _restTimer;
  int _restTimeRemaining = 0;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    _completedSets = List.generate(widget.exercise.sets, (_) => false);
    _restTimeRemaining = widget.exercise.restSeconds;
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _restTimeRemaining = widget.exercise.restSeconds;
      _isResting = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_restTimeRemaining > 1) {
        setState(() {
          _restTimeRemaining--;
        });
      } else {
        timer.cancel();
        HapticFeedback.vibrate();
        setState(() {
          _restTimeRemaining = 0;
          _isResting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Rest time is up! Let's go!", style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: FitzaTheme.primaryDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });
  }

  void _toggleSet(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _completedSets[index] = !_completedSets[index];
    });

    // Auto-trigger rest timer if a set is checked off
    if (_completedSets[index]) {
      _startRestTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final exercise = widget.exercise;
    final completedCount = _completedSets.where((e) => e).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(exercise.name, style: theme.textTheme.titleMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: FitzaTheme.primaryDark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${exercise.name} saved to favorites", style: const TextStyle(color: Colors.white)),
                  backgroundColor: FitzaTheme.primaryDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3D Motion Animated Character Model with Soft Frame
            SoftCard(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ExerciseAnimationWidget(animationType: exercise.animationType, height: 280),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Stats Row Cards
            Row(
              children: [
                Expanded(child: _buildStatChip(theme, Icons.bar_chart_rounded, "Level", exercise.difficulty, FitzaTheme.energyOrange)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatChip(theme, Icons.build_circle_rounded, "Gear", exercise.equipment, FitzaTheme.primaryDark)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatChip(theme, Icons.local_fire_department_rounded, "Burn", "~${exercise.caloriesBurned}", FitzaTheme.accentNeon)),
              ],
            ),

            const SizedBox(height: 32),

            // Target Muscle Highlight Visualizer
            SoftCard(
              padding: const EdgeInsets.all(24),
              child: MuscleGroupHighlightWidget(targetMuscle: exercise.targetMuscle),
            ),

            const SizedBox(height: 32),

            // Interactive Set Completion Progress Tracker
            SoftCard(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.checklist_rounded, color: FitzaTheme.primaryDark, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            "Sets",
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: FitzaTheme.primaryDark.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          "$completedCount / ${exercise.sets}",
                          style: const TextStyle(
                            color: FitzaTheme.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Set Checkbox Items
                  Column(
                    children: List.generate(exercise.sets, (index) {
                      final isDone = _completedSets[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDone
                              ? FitzaTheme.accentNeon.withValues(alpha: 0.1)
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CheckboxListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          title: Text(
                            "Set ${index + 1}",
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              color: isDone ? (isDark ? Colors.white54 : Colors.black54) : (isDark ? Colors.white : Colors.black),
                            ),
                          ),
                          subtitle: Text(
                            "${exercise.reps} Reps • ${exercise.restSeconds}s Rest",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isDark ? Colors.white38 : Colors.black38,
                            )
                          ),
                          value: isDone,
                          activeColor: FitzaTheme.accentNeon,
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onChanged: (_) => _toggleSet(index),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 24),

            // Animated Rest Countdown Timer Card
            if (_isResting)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: FitzaTheme.primaryDark,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            value: _restTimeRemaining / exercise.restSeconds,
                            color: Colors.white,
                            backgroundColor: Colors.black.withValues(alpha: 0.2),
                            strokeWidth: 6,
                          ),
                        ),
                        Text(
                          "${_restTimeRemaining}s",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Resting",
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Take a breath.",
                            style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(ThemeData theme, IconData icon, String label, String value, Color accentColor) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
