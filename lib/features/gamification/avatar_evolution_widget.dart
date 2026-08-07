import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitza/core/fitness_provider.dart';

class AvatarEvolutionWidget extends StatelessWidget {
  const AvatarEvolutionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final int level = provider.userLevel;
    final String stageName = provider.avatarStage;

    // Body metrics evolution math
    final double muscleMass = (level * 1.5 + 40).clamp(40.0, 98.0);
    final double absVisibility = (level * 2.0 + 30).clamp(20.0, 100.0);
    final double shoulderWidth = (level * 1.2 + 50).clamp(50.0, 95.0);
    final double postureRating = (level * 1.8 + 60).clamp(60.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Character Evolution",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Level $level • $stageName",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${provider.userXp} XP",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Central Visual Avatar Card
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Glow Circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.35),
                        Colors.amber.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Stylized Visual Avatar Silhouette
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF2A2A3D) : const Color(0xFFF0F4F8),
                    border: Border.all(
                      color: Colors.amber,
                      width: level >= 30 ? 3 : 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          level >= 50
                              ? Icons.fitness_center_rounded
                              : level >= 30
                                  ? Icons.directions_run_rounded
                                  : Icons.accessibility_new_rounded,
                          size: 48,
                          color: level >= 50 ? Colors.amber : theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "STAGE $level",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Body Metrics Visual Progress Bars
          _buildStatRow(context, "Muscles Growth", muscleMass, Colors.deepOrange),
          const SizedBox(height: 10),
          _buildStatRow(context, "Abs Definition", absVisibility, Colors.amber),
          const SizedBox(height: 10),
          _buildStatRow(context, "Shoulder Width", shoulderWidth, Colors.blue),
          const SizedBox(height: 10),
          _buildStatRow(context, "Posture Score", postureRating, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              "${value.toInt()}%",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / 100.0,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
