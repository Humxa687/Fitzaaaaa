import 'package:flutter/material.dart';

class FormAnalysisScreen extends StatefulWidget {
  const FormAnalysisScreen({super.key});

  @override
  State<FormAnalysisScreen> createState() => _FormAnalysisScreenState();
}

class _FormAnalysisScreenState extends State<FormAnalysisScreen> {
  int _repCount = 12;
  String _postureFeedback = "Keep your back straighter!";
  Color _statusColor = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Form Analysis 🤖"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview Simulation View
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF1E2638), Colors.black],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Simulated Pose Skeleton Keypoints
                  const Icon(Icons.accessibility_new_rounded, size: 240, color: Colors.cyanAccent),
                  Positioned(
                    top: 120,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _statusColor, width: 2),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: _statusColor),
                          const SizedBox(width: 8),
                          Text(
                            _postureFeedback,
                            style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Stats Controller Overlay
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A24).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text("REPS", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("$_repCount", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Container(height: 40, width: 1, color: Colors.grey.shade800),
                  Column(
                    children: [
                      const Text("FORM ACCURACY", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text("94%", style: TextStyle(color: Colors.greenAccent, fontSize: 32, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _repCount++;
                        if (_repCount % 2 == 0) {
                          _postureFeedback = "Great depth! Go lower on next rep.";
                          _statusColor = Colors.greenAccent;
                        } else {
                          _postureFeedback = "Keep your back straighter!";
                          _statusColor = Colors.amber;
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
