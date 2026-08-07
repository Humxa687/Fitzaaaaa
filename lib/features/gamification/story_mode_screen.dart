import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitza/core/fitness_provider.dart';

class StoryModeScreen extends StatelessWidget {
  const StoryModeScreen({super.key});

  final List<Map<String, String>> missions = const [
    {'title': 'Chapter 1: Save the Village', 'goal': 'Complete 100 Squats', 'desc': 'Goblins are raiding the village! Build leg power to push them back.', 'icon': '🛡️'},
    {'title': 'Chapter 2: Climb the Mountain', 'goal': 'Complete 30 Mins HIIT', 'desc': 'Scale the perilous frozen cliff to reach the ancient shrine.', 'icon': '⛰️'},
    {'title': 'Chapter 3: Fight the Shadow Beast', 'goal': 'Burn 500 Active Calories', 'desc': 'Confront the shadow lord in the volcanic arena.', 'icon': '🐉'},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final int chapter = provider.storyChapter;
    final double progress = provider.storyProgress;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitness Story Mode ⚔️"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Chapter Hero Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "HERO'S QUEST",
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    missions[chapter - 1]['title']!,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    missions[chapter - 1]['desc']!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mission Goal: ${missions[chapter - 1]['goal']}",
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Missions List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: missions.length,
              itemBuilder: (context, idx) {
                final m = missions[idx];
                final isCurrent = (idx + 1) == chapter;

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Text(m['icon']!, style: const TextStyle(fontSize: 32)),
                    title: Text(m['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(m['goal']!, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                    trailing: isCurrent
                        ? ElevatedButton(
                            onPressed: () {
                              provider.addXp(150, source: "Story Mission");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("⚔️ Story quest progress updated (+150 XP)!")),
                              );
                            },
                            child: const Text("Battle"),
                          )
                        : const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
