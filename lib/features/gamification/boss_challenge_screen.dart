import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitza/core/fitness_provider.dart';

class BossChallengeScreen extends StatelessWidget {
  const BossChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String bossName = provider.bossName;
    final int maxHp = provider.bossMaxHp;
    final int currentHp = provider.bossCurrentHp;
    final double hpRatio = currentHp / maxHp;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Boss Challenge 👹"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Boss Battle Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF800000), Color(0xFF2B0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "WEEKLY EVENT",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Text(
                        "500 Coins + 1000 XP Reward",
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Boss Visual Artwork
                  const CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.redAccent,
                    child: Text("🐉", style: TextStyle(fontSize: 64)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bossName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Burn calories and complete reps to attack the dragon!",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Boss Health Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "BOSS HP",
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                      Text(
                        "$currentHp / $maxHp HP",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: hpRatio,
                      minHeight: 14,
                      backgroundColor: Colors.black45,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        hpRatio < 0.3 ? Colors.amber : Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Attack Tasks Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Attack Quests",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildAttackQuestRow(
                    context,
                    title: "Complete 50 Push-ups",
                    damage: 150,
                    icon: Icons.fitness_center_rounded,
                    onTap: () {
                      provider.attackBoss(150);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("⚔️ Critical Hit! Boss lost 150 HP!")),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildAttackQuestRow(
                    context,
                    title: "Burn 300 Active Calories",
                    damage: 250,
                    icon: Icons.local_fire_department_rounded,
                    onTap: () {
                      provider.attackBoss(250);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("🔥 Fire Strike! Boss lost 250 HP!")),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildAttackQuestRow(
                    context,
                    title: "Finish 20 Mins Cardio",
                    damage: 200,
                    icon: Icons.directions_run_rounded,
                    onTap: () {
                      provider.attackBoss(200);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("⚡ Lightning Strike! Boss lost 200 HP!")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttackQuestRow(
    BuildContext context, {
    required String title,
    required int damage,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.redAccent),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "-$damage HP",
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
