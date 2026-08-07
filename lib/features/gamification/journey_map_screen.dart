import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitza/core/fitness_provider.dart';

class JourneyMapScreen extends StatelessWidget {
  const JourneyMapScreen({super.key});

  final List<Map<String, String>> mapNodes = const [
    {'name': 'Fitness Village', 'desc': 'Beginner Foundation Workouts', 'icon': '🏡'},
    {'name': 'Enchanted Forest', 'desc': 'Core & Agility Challenges', 'icon': '🌲'},
    {'name': 'Iron Mountain', 'desc': 'Hypertrophy & Strength Training', 'icon': '⛰️'},
    {'name': 'Mystic Temple', 'desc': 'Balance & Endurance Mastery', 'icon': '⛩️'},
    {'name': 'Volcano Crater', 'desc': 'High-Intensity Fat Burner', 'icon': '🌋'},
    {'name': 'Champion Arena', 'desc': 'Ultimate Beast Competitions', 'icon': '🏆'},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final int currentNode = provider.currentMapNode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitness Journey Map 🗺️"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text("🗺️", style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Current Location: ${mapNodes[currentNode]['name']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          "Complete workouts to climb up the realm!",
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // RPG Journey Path List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mapNodes.length,
              itemBuilder: (context, index) {
                final node = mapNodes[index];
                final bool isUnlocked = index <= currentNode;
                final bool isCurrent = index == currentNode;

                return Column(
                  children: [
                    InkWell(
                      onTap: isUnlocked
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("🚀 Teleporting to ${node['name']} routines!")),
                              );
                            }
                          : null,
                      child: Row(
                        children: [
                          // Path Node Circle
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCurrent
                                  ? Colors.amber
                                  : isUnlocked
                                      ? theme.colorScheme.primary
                                      : Colors.grey.withValues(alpha: 0.2),
                              border: Border.all(
                                color: isCurrent ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isCurrent
                                  ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 12)]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                node['icon']!,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Node Title & Description
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isCurrent
                                      ? Colors.amber
                                      : isUnlocked
                                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                                          : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        node['name']!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isUnlocked ? null : Colors.grey,
                                        ),
                                      ),
                                      if (isCurrent)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            "HERE",
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    node['desc']!,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Connector Line
                    if (index < mapNodes.length - 1)
                      Container(
                        margin: const EdgeInsets.only(left: 30),
                        height: 36,
                        width: 4,
                        color: index < currentNode
                            ? theme.colorScheme.primary
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
