import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import 'workout_repository.dart';
import 'exercise_detail_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMuscle = "All";

  final List<String> _muscleFilters = [
    "All",
    "Chest",
    "Quadriceps",
    "Biceps",
    "Deltoids",
    "Abs",
    "Lats",
    "Hamstrings",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allExercises = WorkoutRepository.sampleExercises;

    final filtered = allExercises.where((e) {
      final matchesSearch = e.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          e.targetMuscle.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesMuscle = _selectedMuscle == "All" || e.targetMuscle.toLowerCase() == _selectedMuscle.toLowerCase();
      return matchesSearch && matchesMuscle;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercise Catalog 📚", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search exercises by name or muscle...",
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Horizontal Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: _muscleFilters.map((muscle) {
                final isSel = _selectedMuscle == muscle;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(muscle),
                    selected: isSel,
                    selectedColor: FitzaTheme.energyOrange.withValues(alpha: 0.2),
                    checkmarkColor: FitzaTheme.energyOrange,
                    labelStyle: TextStyle(
                      color: isSel ? FitzaTheme.energyOrange : theme.colorScheme.onSurface,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _selectedMuscle = muscle;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Exercise List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text("No exercises found matching criteria."),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ex = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: FitzaTheme.energyOrange.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.fitness_center_rounded, color: FitzaTheme.energyOrange),
                          ),
                          title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${ex.targetMuscle} • ${ex.difficulty} • ${ex.equipment}"),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExerciseDetailScreen(exercise: ex),
                              ),
                            );
                          },
                        ),
                      ).animate().fade(duration: 300.ms, delay: (index * 50).ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
