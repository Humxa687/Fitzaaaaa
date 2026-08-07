import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitza/core/fitness_provider.dart';

class MonthlyReportDialog extends StatelessWidget {
  const MonthlyReportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Monthly Report 📊", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("JULY 2026", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            _buildReportRow("Workouts Completed", "24 Sessions"),
            _buildReportRow("Calories Burned", "14,850 kcal"),
            _buildReportRow("Longest Streak", "${provider.currentStreak} Days"),
            _buildReportRow("Consistency Score", "96%"),
            _buildReportRow("Top Muscle Group", "Chest & Shoulders"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("📤 Infographic Report Card exported!")),
                  );
                },
                icon: const Icon(Icons.share_rounded),
                label: const Text("Share Report Card 🚀"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
