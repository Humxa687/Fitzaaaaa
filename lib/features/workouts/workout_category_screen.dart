import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/widgets/soft_card.dart';
import 'workout_models.dart';
import 'exercise_detail_screen.dart';

class WorkoutCategoryScreen extends StatelessWidget {
  final WorkoutCategoryModel category;

  const WorkoutCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalCalories = category.exercises.fold<int>(0, (sum, e) => sum + e.caloriesBurned);
    final totalTime = category.exercises.fold<int>(0, (sum, e) => sum + e.durationMinutes);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Clean Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: Text(
                category.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: theme.scaffoldBackgroundColor,
                  ),
                  Positioned(
                    right: -20,
                    bottom: -10,
                    child: Icon(
                      category.icon,
                      size: 200,
                      color: category.gradientColors.first.withValues(alpha: 0.1),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 40.0, bottom: 60.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: category.gradientColors.first.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category.badgeText,
                              style: TextStyle(color: category.gradientColors.first, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            category.description,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Workout Stats Summary Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SoftCard(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryStat(theme, "Exercises", "${category.exercises.length}", Icons.fitness_center_rounded),
                    _buildSummaryStat(theme, "Est. Time", "$totalTime m", Icons.timer_rounded),
                    _buildSummaryStat(theme, "Est. Burn", "$totalCalories kcal", Icons.local_fire_department_rounded),
                  ],
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0),
            ),
          ),

          // List of Exercise Cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final exercise = category.exercises[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: SoftCard(
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExerciseDetailScreen(exercise: exercise),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: FitzaTheme.primaryDark.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.fitness_center_rounded, color: FitzaTheme.primaryDark, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.repeat_rounded, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${exercise.sets} Sets",
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${exercise.durationMinutes} min",
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          exercise.targetMuscle,
                                          style: TextStyle(fontSize: 11, color: FitzaTheme.primaryDark, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          exercise.difficulty,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: exercise.difficulty == "Beginner"
                                                ? FitzaTheme.accentNeon
                                                : exercise.difficulty == "Intermediate"
                                                    ? FitzaTheme.energyOrange
                                                    : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate().fade(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
                },
                childCount: category.exercises.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(ThemeData theme, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: FitzaTheme.primaryDark, size: 28),
        const SizedBox(height: 8),
        Text(value, style: theme.textTheme.titleMedium),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
