import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import '../profile/profile_screen.dart';

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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode Toggle
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
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
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              "WEIGHT LOSS",
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6), 
                                fontWeight: FontWeight.bold, 
                                fontSize: 12
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Already on Body Building
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              "BODY BUILDING",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hi, ${provider.userName} 💪",
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Let's build some muscle today",
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.brightness_6_outlined),
                        onPressed: () {
                          _showThemeBottomSheet(context, provider);
                        },
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                          child: Text(
                            provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : "A",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fade().slideY(begin: -0.2, end: 0, duration: 500.ms),
              
              const SizedBox(height: 24),
              
              // Muscle Group Target
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFB71C1C)], // Red gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Target", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text("Chest & Triceps", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTargetStat("Exercises", "6"),
                        _buildTargetStat("Total Sets", "18"),
                        _buildTargetStat("Intensity", "High"),
                      ],
                    ),
                  ],
                ),
              ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 24),
              
              // Nutrition Focus (Protein heavily featured)
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: theme.colorScheme.surface,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.lunch_dining, color: Colors.orange),
                            const SizedBox(height: 8),
                            const Text("Protein", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("120g / 160g", style: TextStyle(color: theme.colorScheme.primary)),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: 120 / 160,
                              backgroundColor: Colors.orange.withValues(alpha: 0.2),
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      color: theme.colorScheme.surface,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.red),
                            const SizedBox(height: 8),
                            const Text("Calories", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("2100 / ${provider.calorieGoal}", style: TextStyle(color: theme.colorScheme.primary)),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: 2100 / provider.calorieGoal,
                              backgroundColor: Colors.red.withValues(alpha: 0.2),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fade(delay: 400.ms).slideX(begin: 0.2, end: 0, duration: 400.ms),
              
              const SizedBox(height: 24),
              
              const Text("Your Workouts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              _buildWorkoutTile(theme, "Bench Press", "4 Sets x 8-10 Reps", Icons.fitness_center),
              _buildWorkoutTile(theme, "Incline Dumbbell Press", "3 Sets x 10-12 Reps", Icons.fitness_center),
              _buildWorkoutTile(theme, "Tricep Pushdowns", "3 Sets x 12-15 Reps", Icons.fitness_center),
              _buildWorkoutTile(theme, "Overhead Tricep Extension", "3 Sets x 12 Reps", Icons.fitness_center),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildWorkoutTile(ThemeData theme, String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.redAccent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Open detailed workout timer
        },
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context, FitnessProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("App Theme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: AppThemeMode.values.map((mode) {
                  final isSelected = provider.currentTheme == mode;
                  return ChoiceChip(
                    label: Text(mode.name.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        provider.setTheme(mode);
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
