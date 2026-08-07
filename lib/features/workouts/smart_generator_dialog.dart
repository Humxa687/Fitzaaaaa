import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitza/core/fitness_provider.dart';

class SmartGeneratorDialog extends StatefulWidget {
  const SmartGeneratorDialog({super.key});

  @override
  State<SmartGeneratorDialog> createState() => _SmartGeneratorDialogState();
}

class _SmartGeneratorDialogState extends State<SmartGeneratorDialog> {
  int _energyLevel = 3; // 1-5
  int _availableMinutes = 20;
  String _location = "Home";
  String _focusArea = "Full Body";

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
            const Row(
              children: [
                Text("🧠", style: TextStyle(fontSize: 28)),
                SizedBox(width: 10),
                Text(
                  "Smart Generator",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Energy Level
            Text("How is your energy level today? ($_energyLevel/5)"),
            Slider(
              value: _energyLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: "$_energyLevel",
              onChanged: (val) => setState(() => _energyLevel = val.toInt()),
            ),

            // Available Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Available Time:"),
                DropdownButton<int>(
                  value: _availableMinutes,
                  items: const [
                    DropdownMenuItem(value: 15, child: Text("15 Mins")),
                    DropdownMenuItem(value: 20, child: Text("20 Mins")),
                    DropdownMenuItem(value: 30, child: Text("30 Mins")),
                    DropdownMenuItem(value: 45, child: Text("45 Mins")),
                  ],
                  onChanged: (val) => setState(() => _availableMinutes = val ?? 20),
                ),
              ],
            ),

            // Location
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Location:"),
                DropdownButton<String>(
                  value: _location,
                  items: const [
                    DropdownMenuItem(value: "Home", child: Text("Home (Bodyweight)")),
                    DropdownMenuItem(value: "Gym", child: Text("Gym (Weights)")),
                  ],
                  onChanged: (val) => setState(() => _location = val ?? "Home"),
                ),
              ],
            ),

            // Focus Area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Target Focus:"),
                DropdownButton<String>(
                  value: _focusArea,
                  items: const [
                    DropdownMenuItem(value: "Full Body", child: Text("Full Body")),
                    DropdownMenuItem(value: "Chest & Arms", child: Text("Chest & Arms")),
                    DropdownMenuItem(value: "Legs & Core", child: Text("Legs & Core")),
                    DropdownMenuItem(value: "HIIT Cardio", child: Text("HIIT Cardio")),
                  ],
                  onChanged: (val) => setState(() => _focusArea = val ?? "Full Body"),
                ),
              ],
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  provider.addXp(50, source: "Custom AI Workout");
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("⚡ Generated $_availableMinutes min $_location Custom $_focusArea Routine!"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Generate Custom Workout 🚀"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
