import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import 'workout_models.dart';
import 'exercise_animation_widget.dart';
import 'workout_replay_dialog.dart';

class WorkoutPlayerScreen extends StatefulWidget {
  final List<ExerciseModel> exercises;
  final String workoutTitle;

  const WorkoutPlayerScreen({
    super.key,
    required this.exercises,
    required this.workoutTitle,
  });

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 1;
  bool _isPaused = false;
  bool _isResting = false;

  Timer? _exerciseTimer;
  Timer? _restTimer;
  int _exerciseSeconds = 0;
  int _restSecondsRemaining = 0;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _startExerciseTimer();
  }

  @override
  void dispose() {
    _exerciseTimer?.cancel();
    _restTimer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _startExerciseTimer() {
    _exerciseTimer?.cancel();
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isResting && mounted) {
        setState(() {
          _exerciseSeconds++;
        });
      }
    });
  }

  void _startRestTimer() {
    _exerciseTimer?.cancel();
    final currentEx = widget.exercises[_currentExerciseIndex];
    int restTime = currentEx.restSeconds;

    bool isWorkoutFinished = false;

    if (_currentSetIndex < currentEx.sets) {
      setState(() {
        _currentSetIndex++;
      });
    } else {
      if (_currentExerciseIndex < widget.exercises.length - 1) {
        setState(() {
          _currentExerciseIndex++;
          _currentSetIndex = 1;
        });
      } else {
        isWorkoutFinished = true;
      }
    }

    if (isWorkoutFinished) {
      _finishWorkout();
      return;
    }

    setState(() {
      _isResting = true;
      _restSecondsRemaining = restTime;
    });

    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_restSecondsRemaining > 1) {
        setState(() {
          _restSecondsRemaining--;
        });
      } else {
        timer.cancel();
        _skipRest();
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _isResting = false;
      _exerciseSeconds = 0;
    });
    _startExerciseTimer();
  }

  void _advanceWithoutRest() {
    _exerciseTimer?.cancel();

    bool isWorkoutFinished = false;
    final currentEx = widget.exercises[_currentExerciseIndex];
    
    if (_currentSetIndex < currentEx.sets) {
      setState(() {
        _currentSetIndex++;
      });
    } else {
      if (_currentExerciseIndex < widget.exercises.length - 1) {
        setState(() {
          _currentExerciseIndex++;
          _currentSetIndex = 1;
        });
      } else {
        isWorkoutFinished = true;
      }
    }

    if (isWorkoutFinished) {
      _finishWorkout();
      return;
    }

    setState(() {
      _exerciseSeconds = 0;
    });
    _startExerciseTimer();
  }

  void _addRestTime() {
    setState(() {
      _restSecondsRemaining += 20;
    });
  }

  void _finishWorkout() {
    _exerciseTimer?.cancel();
    _restTimer?.cancel();
    _confettiController.play();

    final provider = Provider.of<FitnessProvider>(context, listen: false);
    provider.logWorkoutCompleted(
      name: widget.workoutTitle,
      calories: 280,
      xp: 250,
      muscles: ['Chest', 'Arms', 'Shoulders'],
      durationMinutes: max(1, _exerciseSeconds ~/ 60),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WorkoutReplayDialog(
        workoutName: widget.workoutTitle,
        calories: 280,
        xp: 250,
        muscles: const ['Chest', 'Arms', 'Shoulders'],
      ),
    ).then((_) {
      if (mounted) {
        Navigator.pop(context); // Return to dashboard
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentEx = widget.exercises[_currentExerciseIndex];
    final nextEx = (_currentExerciseIndex < widget.exercises.length - 1)
        ? widget.exercises[_currentExerciseIndex + 1]
        : null;

    final progressFactor = (_currentExerciseIndex + 1) / widget.exercises.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
            onPressed: () {
              setState(() => _isPaused = !_isPaused);
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Confetti overlay for completion
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.orange, Colors.red, Colors.green, Colors.blue, Colors.amber],
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Progress Bar
                LinearProgressIndicator(
                  value: progressFactor,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  color: FitzaTheme.energyOrange,
                  minHeight: 6,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [

                        // Exercise Counter Header
                        Center(
                          child: Text(
                            "EXERCISE ${_currentExerciseIndex + 1} OF ${widget.exercises.length}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Large 2D Motion Character Animation Canvas
                        ExerciseAnimationWidget(
                          animationType: currentEx.animationType, 
                          height: 250,
                          state: _isResting 
                              ? ExerciseState.resting 
                              : (_isPaused ? ExerciseState.idle : ExerciseState.active),
                        ),

                        const SizedBox(height: 20),

                        // Exercise Title & Muscle Target Badge
                        Text(
                          currentEx.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.my_location_rounded, size: 16, color: FitzaTheme.energyOrange),
                            const SizedBox(width: 4),
                            Text(
                              "${currentEx.targetMuscle} • ${currentEx.equipment}",
                              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Sets & Reps Target Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "SET $_currentSetIndex OF ${currentEx.sets}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentEx.reps,
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: FitzaTheme.energyOrange),
                                  ),
                                ],
                              ),
                              Container(width: 1, height: 40, color: Colors.white24),
                              Column(
                                children: [
                                  const Text("REST TARGET", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${currentEx.restSeconds}s",
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Upcoming Exercise Preview Card
                        if (nextEx != null)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.skip_next_rounded, color: FitzaTheme.energyOrange),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("UPCOMING EXERCISE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      Text(nextEx.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Player Bottom Controls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Complete Set button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                          label: const Text(
                            "COMPLETE SET",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5),
                          ),
                          onPressed: () => _startRestTimer(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Timer moved above play button
                      Center(
                        child: Text(
                          "${(_exerciseSeconds ~/ 60).toString().padLeft(2, '0')}:${(_exerciseSeconds % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: FitzaTheme.energyOrange,
                          ),
                        ).animate(target: _isPaused ? 1 : 0).fade(end: 0.5),
                      ),
                      const SizedBox(height: 16),
                      // Media Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_rounded, size: 36, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _exerciseSeconds = 0;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded, size: 48),
                            onPressed: _currentExerciseIndex > 0
                                ? () {
                                    setState(() {
                                      _currentExerciseIndex--;
                                      _currentSetIndex = 1;
                                      _exerciseSeconds = 0;
                                    });
                                  }
                                : null,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _isPaused = !_isPaused);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: const BoxDecoration(
                                color: FitzaTheme.energyOrange,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded, size: 48),
                            onPressed: () => _advanceWithoutRest(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Animated Rest Timer Modal Overlay
          if (_isResting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "REST & RECOVER",
                        style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 24),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: _restSecondsRemaining / currentEx.restSeconds,
                              color: FitzaTheme.energyOrange,
                              backgroundColor: Colors.white12,
                              strokeWidth: 10,
                            ),
                          ),
                          Text(
                            "${_restSecondsRemaining}s",
                            style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text("+20 Sec Rest"),
                            onPressed: _addRestTime,
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FitzaTheme.energyOrange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                            label: const Text("Skip Rest", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            onPressed: _skipRest,
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
              ),
            ),
        ],
      ),
    );
  }
}
