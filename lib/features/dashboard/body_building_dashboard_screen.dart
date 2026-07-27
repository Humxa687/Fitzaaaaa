import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/soft_card.dart';
import '../profile/profile_screen.dart';
import '../workouts/workout_models.dart';
import '../workouts/workout_repository.dart';
import '../workouts/workout_category_screen.dart';
import '../workouts/exercise_library_screen.dart';
import '../workouts/workout_player_screen.dart';
import '../workouts/custom_workout_builder_dialog.dart';
import '../workouts/exercise_animation_widget.dart';

class BodyBuildingDashboardScreen extends StatefulWidget {
  const BodyBuildingDashboardScreen({super.key});

  @override
  State<BodyBuildingDashboardScreen> createState() => _BodyBuildingDashboardScreenState();
}

class _BodyBuildingDashboardScreenState extends State<BodyBuildingDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);
    final categories = WorkoutRepository.getAllCategories();
    final personalizedWorkout = WorkoutRepository.generatePersonalizedWorkout(provider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Hi, ${provider.userName}",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          provider.currentTheme == AppThemeMode.light ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          provider.setTheme(
                            provider.currentTheme == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: FitzaTheme.primaryDark.withValues(alpha: 0.1),
                          child: Text(
                            provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : "A",
                            style: theme.textTheme.titleLarge?.copyWith(color: FitzaTheme.primaryDark),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fade().slideY(begin: -0.1),

              const SizedBox(height: 32),

              // Soft Segmented Control for Goal
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          provider.updateProfile(
                            name: provider.userName,
                            age: provider.age,
                            weight: provider.weight,
                            height: provider.height,
                            fitnessGoal: "Weight Loss",
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              "Weight Loss",
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Body Building",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 100.ms),

              const SizedBox(height: 32),

              // Clean Hero Workout Card
              SoftCard(
                padding: const EdgeInsets.all(28),
                borderRadius: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("DAILY PLAN", style: theme.textTheme.labelLarge?.copyWith(
                          color: FitzaTheme.primaryDark,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                        )),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: FitzaTheme.primaryDark.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text("CORE", style: theme.textTheme.labelSmall?.copyWith(
                            color: FitzaTheme.primaryDark,
                            fontWeight: FontWeight.w700,
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      personalizedWorkout.title,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeroStat(theme, "${personalizedWorkout.exercises.length}", "Exercises"),
                        _buildHeroStat(theme, "${personalizedWorkout.exercises.fold<int>(0, (sum, e) => sum + e.durationMinutes)} min", "Duration"),
                        _buildHeroStat(theme, personalizedWorkout.level, "Intensity"),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FitzaTheme.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutPlayerScreen(
                                exercises: personalizedWorkout.exercises,
                                workoutTitle: personalizedWorkout.title,
                              ),
                            ),
                          );
                        },
                        child: const Text("Start Workout"),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.05),

              const SizedBox(height: 24),

              // Activity Rings / Metrics Grid
              Row(
                children: [
                  Expanded(
                    child: SoftCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: FitzaTheme.energyOrange.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_fire_department_rounded, color: FitzaTheme.energyOrange, size: 28),
                          ),
                          const SizedBox(height: 16),
                          Text("${provider.caloriesBurned}", style: theme.textTheme.headlineMedium?.copyWith(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                          Text("Calories", style: theme.textTheme.labelMedium?.copyWith(color: isDark ? Colors.white54 : Colors.black54)),
                        ],
                      ),
                    ).animate().fade(delay: 300.ms),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SoftCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: FitzaTheme.accentNeon.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.timer_rounded, color: FitzaTheme.accentNeon, size: 28),
                          ),
                          const SizedBox(height: 16),
                          Text("${provider.activeMinutes}", style: theme.textTheme.headlineMedium?.copyWith(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                          Text("Minutes", style: theme.textTheme.labelMedium?.copyWith(color: isDark ? Colors.white54 : Colors.black54)),
                        ],
                      ),
                    ).animate().fade(delay: 400.ms),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Explore Workouts", style: theme.textTheme.titleLarge),
                  IconButton(
                    icon: Icon(Icons.add_rounded, color: FitzaTheme.primaryDark, size: 28),
                    onPressed: () {
                      CustomWorkoutBuilderDialog.show(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Soft Grid of Categories
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return GestureDetector(
                    onTap: () {
                      if (cat.id == "cat_library") {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExerciseLibraryScreen()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutCategoryScreen(category: cat)));
                      }
                    },
                    child: SoftCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cat.gradientColors.first.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(cat.icon, color: cat.gradientColors.first, size: 28),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat.level,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(duration: 400.ms, delay: (index * 50).ms).slideY(begin: 0.05);
                },
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStat(ThemeData theme, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.brightness == Brightness.dark ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }
  Widget _buildQuickExerciseCard(BuildContext context, String title, String modelPath, String muscle, ExerciseModel exercise) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: exercise)));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: FitzaTheme.primaryDark.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fitness_center_rounded, color: FitzaTheme.primaryDark, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(muscle, style: theme.textTheme.labelMedium?.copyWith(color: FitzaTheme.primaryDark)),
          ],
        ),
      ),
    );
  }
}
