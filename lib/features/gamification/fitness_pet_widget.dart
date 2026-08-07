import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitza/core/fitness_provider.dart';

class FitnessPetWidget extends StatelessWidget {
  const FitnessPetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String petName = provider.petName;
    final int health = provider.petHealth;
    final String mood = provider.petMood;
    final int level = provider.petLevel;
    final String outfit = provider.petOutfit;

    Color moodColor = Colors.green;
    String petEmoji = "🐶";
    if (mood.toLowerCase() == "energetic") {
      moodColor = Colors.orange;
      petEmoji = "🐕⚡";
    } else if (health < 40) {
      moodColor = Colors.red;
      petEmoji = "🐶💤";
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.25),
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
                      color: Colors.purple.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Text("🐶", style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$petName the Fit Pet",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Level $level • Outfit: $outfit",
                        style: TextStyle(
                          color: Colors.purple.shade300,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: moodColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  mood,
                  style: TextStyle(
                    color: moodColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Central Interactive Pet Card
          InkWell(
            onTap: () {
              provider.interactWithPet();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("🐶 $petName loves your workout energy! Health restored!"),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2D1F3F), const Color(0xFF1E1E2E)]
                      : [Colors.purple.shade50, Colors.pink.shade50],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    petEmoji,
                    style: const TextStyle(fontSize: 56),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tap to Play & Feed 🍎",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Pet Health Bar
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              const Text(
                "Health",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                "$health / 100",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: health / 100.0,
              minHeight: 8,
              backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
