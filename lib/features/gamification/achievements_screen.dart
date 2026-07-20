import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/fitness_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);

    // Dynamic Badges logic
    final badges = [
      _BadgeData("First Steps", "Reach 1,000 steps in a day.", Icons.directions_walk, provider.todaySteps >= 1000),
      _BadgeData("10K Club", "Reach 10,000 steps.", Icons.star, provider.todaySteps >= 10000),
      _BadgeData("3-Day Streak", "Hit your goal 3 days in a row.", Icons.local_fire_department, provider.currentStreak >= 3),
      _BadgeData("7-Day Streak", "Hit your goal 7 days in a row.", Icons.local_fire_department, provider.currentStreak >= 7),
      _BadgeData("Level 2", "Earn 1000 XP.", Icons.upgrade, provider.userLevel >= 2),
      _BadgeData("Elite Mover", "Reach Elite level.", Icons.diamond, provider.userLevel >= 10),
      _BadgeData("Hydration Hero", "Drink 8 glasses of water today.", Icons.water_drop, provider.waterIntake >= 8),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          return _buildBadgeCard(badge, theme, index);
        },
      ),
    );
  }

  Widget _buildBadgeCard(_BadgeData badge, ThemeData theme, int index) {
    return Card(
      elevation: badge.isUnlocked ? 8 : 2,
      color: badge.isUnlocked ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: badge.isUnlocked
                    ? const LinearGradient(colors: [Colors.orange, Colors.deepOrange])
                    : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600]),
              ),
              child: Icon(badge.icon, size: 40, color: Colors.white),
            )
                .animate(target: badge.isUnlocked ? 1 : 0)
                .shimmer(duration: 2000.ms)
                .scaleXY(begin: 1, end: 1.05, duration: 800.ms, curve: Curves.easeInOut)
                .then(delay: 800.ms)
                .scaleXY(begin: 1.05, end: 1),
            const SizedBox(height: 12),
            Text(
              badge.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: badge.isUnlocked ? theme.colorScheme.onPrimaryContainer : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              style: TextStyle(
                fontSize: 12,
                color: badge.isUnlocked ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7) : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ).animate().fade(duration: 500.ms, delay: (100 * index).ms).slideY(begin: 0.2, end: 0, duration: 500.ms),
    );
  }
}

class _BadgeData {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  _BadgeData(this.title, this.description, this.icon, this.isUnlocked);
}
