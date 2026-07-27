import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import 'workout_models.dart';
import 'workout_repository.dart';

class CustomWorkoutBuilderDialog extends StatefulWidget {
  const CustomWorkoutBuilderDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CustomWorkoutBuilderDialog(),
    );
  }

  @override
  State<CustomWorkoutBuilderDialog> createState() => _CustomWorkoutBuilderDialogState();
}

class _CustomWorkoutBuilderDialogState extends State<CustomWorkoutBuilderDialog> {
  final TextEditingController _nameController = TextEditingController(text: "My Custom Routine");
  final List<ExerciseModel> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    // Default pick 2 exercises
    _selectedExercises.addAll(WorkoutRepository.sampleExercises.take(2));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = WorkoutRepository.sampleExercises;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Create Custom Workout Routine 🛠️", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Routine Name Field
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Routine Name",
              prefixIcon: const Icon(Icons.edit_note_rounded),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Selected Exercises (${_selectedExercises.length})", style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_rounded, color: FitzaTheme.energyOrange),
                onPressed: () {
                  _showAddExercisePicker(available);
                },
              ),
            ],
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _selectedExercises.length,
              itemBuilder: (context, index) {
                final ex = _selectedExercises[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: FitzaTheme.energyOrange.withValues(alpha: 0.15),
                      child: Text("${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: FitzaTheme.energyOrange)),
                    ),
                    title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${ex.sets} Sets • ${ex.reps}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedExercises.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Save Routine Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: FitzaTheme.energyOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              label: const Text("Save Custom Routine to Cloud", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: () {
                if (_nameController.text.trim().isEmpty || _selectedExercises.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a routine name and select at least 1 exercise.")),
                  );
                  return;
                }

                final provider = Provider.of<FitnessProvider>(context, listen: false);
                provider.syncDataToCloud(); // Sync to Cloud

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Custom Routine '${_nameController.text}' saved to Cloud! 🎉")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExercisePicker(List<ExerciseModel> available) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Add Exercise to Routine", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final ex = available[index];
                  return ListTile(
                    title: Text(ex.name),
                    subtitle: Text("${ex.targetMuscle} • ${ex.equipment}"),
                    onTap: () {
                      setState(() {
                        if (!_selectedExercises.contains(ex)) {
                          _selectedExercises.add(ex);
                        }
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
