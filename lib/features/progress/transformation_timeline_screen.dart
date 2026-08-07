import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitza/core/fitness_provider.dart';

class TransformationTimelineScreen extends StatefulWidget {
  const TransformationTimelineScreen({super.key});

  @override
  State<TransformationTimelineScreen> createState() => _TransformationTimelineScreenState();
}

class _TransformationTimelineScreenState extends State<TransformationTimelineScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);
    final photos = provider.transformationPhotos;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transformation Timeline 📸"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Swipe Left / Right to Compare Progress",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 14),

            // Interactive Before vs After Comparison Card
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF232526), Color(0xFF414345)],
                ),
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      // Before Side
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.15),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              bottomLeft: Radius.circular(24),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.accessibility_new_rounded, size: 80, color: Colors.blueAccent),
                              SizedBox(height: 10),
                              Text("MONTH 1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text("Before (74.5 kg)", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      // After Side
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withValues(alpha: 0.15),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fitness_center_rounded, size: 80, color: Colors.deepOrange),
                              SizedBox(height: 10),
                              Text("MONTH 6", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text("After (68.0 kg Shredded)", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Center(
                    child: VerticalDivider(color: Colors.white, thickness: 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Video Timelapse Generator Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("🎬 Generating 1080p Timelapse Video Preview...")),
                  );
                },
                icon: const Icon(Icons.movie_creation_rounded, color: Colors.amber),
                label: const Text("Generate Transformation Video 🎬"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Monthly Photo Logs",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: photos.length,
              itemBuilder: (context, idx) {
                final photo = photos[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.camera_alt_rounded, color: Colors.black),
                    ),
                    title: Text(photo['date']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(photo['label']!),
                    trailing: Chip(
                      label: Text(photo['tag']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
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
