import 'package:flutter/material.dart';

enum ExerciseAnimationType {
  pushup,
  benchPress,
  bicepCurl,
  squat,
  shoulderPress,
  plank,
  crunch,
  pullup,
  deadlift,
  lunge
}

class ExerciseModel {
  final String id;
  final String name;
  final String targetMuscle;
  final String difficulty; // Beginner, Intermediate, Advanced
  final String equipment; // Bodyweight, Dumbbell, Barbell, Cable, Machine
  final int sets;
  final String reps;
  final int restSeconds;
  final int caloriesBurned;
  final int durationMinutes;
  final ExerciseAnimationType animationType;
  final List<String> instructions;
  final List<String> commonMistakes;
  final List<String> formTips;
  final List<String> alternatives;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.targetMuscle,
    required this.difficulty,
    required this.equipment,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.caloriesBurned,
    required this.durationMinutes,
    required this.animationType,
    required this.instructions,
    required this.commonMistakes,
    required this.formTips,
    required this.alternatives,
  });
}

class WorkoutCategoryModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String badgeText;
  final String level;
  final List<ExerciseModel> exercises;

  const WorkoutCategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.badgeText,
    required this.level,
    required this.exercises,
  });
}
