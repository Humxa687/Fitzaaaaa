import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitza/core/fitness_provider.dart';

class RecoveryScoreCard extends StatelessWidget {
  const RecoveryScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final int score = provider.recoveryScore;
    final double sleep = provider.sleepHours;
    final String soreness = provider.sorenessLevel;

    Color scoreColor = Colors.green;
    if (score < 60) scoreColor = Colors.redAccent;
    if (score < 80) scoreColor = Colors.amber;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 22),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Recovery Score",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "$score% Readiness",
                  style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text("Sleep Duration", style: TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("${sleep}h", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ],
                ),
              ),
              Container(height: 24, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
              Expanded(
                child: Column(
                  children: [
                    const Text("Muscle Soreness", style: TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(soreness, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
              ),
              Container(height: 24, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
              Expanded(
                child: Column(
                  children: [
                    const Text("Suggested Day", style: TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        score >= 75 ? "Heavy Workout" : "Light Recovery",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: scoreColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
