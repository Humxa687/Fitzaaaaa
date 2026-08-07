import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitza/core/fitness_provider.dart';
import 'avatar_evolution_widget.dart';
import 'fitness_pet_widget.dart';
import 'boss_challenge_screen.dart';
import 'journey_map_screen.dart';
import 'story_mode_screen.dart';
import 'shop_screen.dart';
import 'mystery_box_dialog.dart';
import 'leaderboard_screen.dart';
import 'achievements_screen.dart';

class GamificationHubScreen extends StatelessWidget {
  const GamificationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gamification Hub 🎮"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.card_giftcard_rounded, color: Colors.amber),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const MysteryBoxDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.storefront_rounded, color: Colors.amber),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Streak Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepOrange, Colors.orangeAccent],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Text("🔥", style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${provider.currentStreak} Day Workout Streak!",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          "Streak Freezes: ${provider.streakFreezes} 🛡️",
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      provider.buyStreakFreeze();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("🛡️ Bought 1 Streak Freeze!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Buy Freeze"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Character Avatar Evolution Widget
            const AvatarEvolutionWidget(),
            const SizedBox(height: 20),

            // Virtual Fitness Pet
            const FitnessPetWidget(),
            const SizedBox(height: 24),

            // Quick Shortcut Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.3,
              children: [
                _buildGamificationCard(
                  context,
                  title: "Boss Battles",
                  subtitle: "Defeat Inferno Dragon",
                  icon: "👹",
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BossChallengeScreen())),
                ),
                _buildGamificationCard(
                  context,
                  title: "Journey Map",
                  subtitle: "Explore 6 Realms",
                  icon: "🗺️",
                  color: Colors.amber,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JourneyMapScreen())),
                ),
                _buildGamificationCard(
                  context,
                  title: "Story Mode",
                  subtitle: "Hero Quest Chapter 1",
                  icon: "⚔️",
                  color: Colors.blueAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryModeScreen())),
                ),
                _buildGamificationCard(
                  context,
                  title: "Leaderboard",
                  subtitle: "Global Competitions",
                  icon: "🏆",
                  color: Colors.purpleAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Achievements Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
                icon: const Icon(Icons.military_tech_rounded, color: Colors.amber),
                label: const Text("View All 9 Badges & Trophies"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamificationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
