import 'package:flutter/material.dart';

class WorkoutReplayDialog extends StatelessWidget {
  final String workoutName;
  final int calories;
  final int xp;
  final List<String> muscles;

  const WorkoutReplayDialog({
    super.key,
    required this.workoutName,
    required this.calories,
    required this.xp,
    required this.muscles,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1E2E), Color(0xFF0F0F1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Colors.amber,
              child: Icon(Icons.emoji_events_rounded, size: 40, color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text(
              "WORKOUT REPLAY 🎬",
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            Text(
              workoutName,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text("CALORIES", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("🔥 $calories", style: const TextStyle(color: Colors.deepOrange, fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
                Column(
                  children: [
                    const Text("XP GAINED", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("⚡ +$xp", style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Muscles Glowing: ${muscles.join(', ')}",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Awesome! Finish"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
