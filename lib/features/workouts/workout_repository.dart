import 'package:flutter/material.dart';
import 'workout_models.dart';
import '../../core/fitness_provider.dart';

class WorkoutRepository {
  static const List<ExerciseModel> sampleExercises = [
    ExerciseModel(
      id: "ex_pushup",
      name: "Standard Push-Ups",
      targetMuscle: "Chest",
      difficulty: "Beginner",
      equipment: "Bodyweight",
      sets: 3,
      reps: "12-15 reps",
      restSeconds: 45,
      caloriesBurned: 85,
      durationMinutes: 10,
      animationType: ExerciseAnimationType.pushup,
      instructions: [
        "Place your hands slightly wider than shoulder-width apart on the floor.",
        "Extend your legs back so you are balanced on your hands and toes.",
        "Keep your body in a straight line from head to heels without sagging your hips.",
        "Lower your chest towards the floor until your elbows form a 90-degree angle.",
        "Push back up to the starting position smoothly."
      ],
      commonMistakes: [
        "Flaring elbows outwards at a 90-degree angle from body.",
        "Sagging hips or arching upper back.",
        "Not going through a full range of motion."
      ],
      formTips: [
        "Keep your core engaged throughout the entire movement.",
        "Position your elbows at a 45-degree angle to protect your shoulders.",
        "Inhale on the way down, exhale as you push up."
      ],
      alternatives: ["Knee Push-Ups", "Incline Push-Ups on Bench", "Wall Push-Ups"],
    ),
    ExerciseModel(
      id: "ex_bench_press",
      name: "Barbell Bench Press",
      targetMuscle: "Chest",
      difficulty: "Intermediate",
      equipment: "Barbell",
      sets: 4,
      reps: "8-10 reps",
      restSeconds: 90,
      caloriesBurned: 140,
      durationMinutes: 15,
      animationType: ExerciseAnimationType.benchPress,
      instructions: [
        "Lie flat on the bench with feet firmly planted on the ground.",
        "Grasp the barbell with hands slightly wider than shoulder-width.",
        "Unrack the bar and hold it directly above your chest with arms extended.",
        "Lower the bar slowly to mid-chest level in a controlled arc.",
        "Press the bar back up powerfully to starting position."
      ],
      commonMistakes: [
        "Bouncing the bar off your sternum.",
        "Lifting your glutes off the bench during heavy effort."
      ],
      formTips: [
        "Retract your shoulder blades and pin them against the bench.",
        "Drive your feet into the floor for leg drive."
      ],
      alternatives: ["Dumbbell Chest Press", "Machine Chest Press"],
    ),
    ExerciseModel(
      id: "ex_squat",
      name: "Barbell Squats",
      targetMuscle: "Legs",
      difficulty: "Intermediate",
      equipment: "Barbell",
      sets: 4,
      reps: "10-12 reps",
      restSeconds: 90,
      caloriesBurned: 180,
      durationMinutes: 18,
      animationType: ExerciseAnimationType.squat,
      instructions: [
        "Rest the barbell comfortably across your upper traps.",
        "Stand with feet shoulder-width apart, toes pointed slightly outwards.",
        "Hinge at your hips and bend knees simultaneously to lower your torso.",
        "Descend until your thighs are parallel or below parallel to the floor.",
        "Drive through your heels to stand back up into starting position."
      ],
      commonMistakes: [
        "Allowing knees to cave inward (valgus collapse).",
        "Rounding the lower back at the bottom of the squat."
      ],
      formTips: [
        "Take a deep breath into your diaphragm and brace your core tightly.",
        "Keep your head up and chest open throughout."
      ],
      alternatives: ["Goblet Squat", "Leg Press Machine"],
    ),
    ExerciseModel(
      id: "ex_deadlift",
      name: "Barbell Deadlift",
      targetMuscle: "Back",
      difficulty: "Advanced",
      equipment: "Barbell",
      sets: 4,
      reps: "5-8 reps",
      restSeconds: 120,
      caloriesBurned: 200,
      durationMinutes: 20,
      animationType: ExerciseAnimationType.deadlift,
      instructions: [
        "Stand with mid-foot under the barbell.",
        "Bend over and grab the bar with a shoulder-width grip.",
        "Bend your knees until your shins touch the bar.",
        "Lift your chest up and straighten your lower back.",
        "Stand up with the weight by driving through your heels."
      ],
      commonMistakes: [
        "Rounding the lower back during the pull.",
        "Jerking the weight off the floor."
      ],
      formTips: [
        "Keep the bar as close to your body as possible.",
        "Squeeze your glutes at the top."
      ],
      alternatives: ["Romanian Deadlift", "Trap Bar Deadlift"],
    ),
    ExerciseModel(
      id: "ex_pullup",
      name: "Pull-Ups",
      targetMuscle: "Back",
      difficulty: "Advanced",
      equipment: "Bodyweight",
      sets: 4,
      reps: "8-10 reps",
      restSeconds: 90,
      caloriesBurned: 130,
      durationMinutes: 14,
      animationType: ExerciseAnimationType.pullup,
      instructions: [
        "Grasp a pull-up bar with an overhand grip slightly wider than shoulders.",
        "Hang at full arm extension with feet crossed behind.",
        "Pull your chest up toward the bar by driving your elbows down.",
        "Continue until your chin clears the bar.",
        "Lower yourself down slowly under control to dead hang."
      ],
      commonMistakes: ["Kicking legs or swinging hips.", "Partial reps."],
      formTips: ["Depress your scapula before pulling.", "Keep core tight."],
      alternatives: ["Lat Pulldown", "Assisted Pull-Ups"],
    ),
    ExerciseModel(
      id: "ex_lat_pulldown",
      name: "Lat Pulldown",
      targetMuscle: "Back",
      difficulty: "Beginner",
      equipment: "Machine",
      sets: 3,
      reps: "10-12 reps",
      restSeconds: 60,
      caloriesBurned: 90,
      durationMinutes: 10,
      animationType: ExerciseAnimationType.pullup,
      instructions: [
        "Sit on the machine and adjust the knee pad.",
        "Grab the bar with a wide grip.",
        "Pull the bar down to your upper chest.",
        "Squeeze your back muscles, then slowly return."
      ],
      commonMistakes: ["Leaning too far back.", "Using momentum."],
      formTips: ["Drive elbows down and back.", "Keep chest up."],
      alternatives: ["Pull-Ups", "Straight Arm Pulldown"],
    ),
    ExerciseModel(
      id: "ex_shoulder_press",
      name: "Shoulder Press",
      targetMuscle: "Shoulders",
      difficulty: "Intermediate",
      equipment: "Dumbbell",
      sets: 3,
      reps: "10-12 reps",
      restSeconds: 60,
      caloriesBurned: 110,
      durationMinutes: 12,
      animationType: ExerciseAnimationType.shoulderPress,
      instructions: [
        "Hold dumbbells at shoulder height with palms facing forward.",
        "Press the dumbbells overhead until arms are extended.",
        "Lower the weights slowly back to shoulder level."
      ],
      commonMistakes: ["Arching lower back.", "Pressing weights forward."],
      formTips: ["Brace abdominal muscles.", "Keep head neutral."],
      alternatives: ["Machine Shoulder Press", "Barbell OHP"],
    ),
    ExerciseModel(
      id: "ex_dumbbell_row",
      name: "Dumbbell Rows",
      targetMuscle: "Back",
      difficulty: "Beginner",
      equipment: "Dumbbell",
      sets: 3,
      reps: "10-12 reps",
      restSeconds: 60,
      caloriesBurned: 100,
      durationMinutes: 12,
      animationType: ExerciseAnimationType.deadlift,
      instructions: [
        "Place one knee and hand on a bench.",
        "Hold a dumbbell in the other hand, arm extended.",
        "Pull the dumbbell up to your hip.",
        "Lower slowly."
      ],
      commonMistakes: ["Twisting torso.", "Pulling with bicep."],
      formTips: ["Keep back flat.", "Squeeze shoulder blade at top."],
      alternatives: ["Barbell Row", "Cable Row"],
    ),
    ExerciseModel(
      id: "ex_lunges",
      name: "Lunges",
      targetMuscle: "Legs",
      difficulty: "Beginner",
      equipment: "Bodyweight",
      sets: 3,
      reps: "10-12 reps / leg",
      restSeconds: 60,
      caloriesBurned: 120,
      durationMinutes: 15,
      animationType: ExerciseAnimationType.lunge,
      instructions: [
        "Step forward with one leg and lower your hips.",
        "Both knees should be bent at a 90-degree angle.",
        "Push back up to the starting position."
      ],
      commonMistakes: ["Front knee extending past toes.", "Leaning forward."],
      formTips: ["Keep torso upright.", "Drive through front heel."],
      alternatives: ["Bulgarian Split Squat", "Leg Press"],
    ),
    ExerciseModel(
      id: "ex_plank",
      name: "Plank",
      targetMuscle: "Abs & Core",
      difficulty: "Beginner",
      equipment: "Bodyweight",
      sets: 3,
      reps: "45-60 seconds",
      restSeconds: 30,
      caloriesBurned: 60,
      durationMinutes: 8,
      animationType: ExerciseAnimationType.plank,
      instructions: [
        "Place forearms on the floor, elbows under shoulders.",
        "Extend legs behind you balanced on toes.",
        "Keep body in a rigid straight line."
      ],
      commonMistakes: ["Sagging lower back.", "Hips too high."],
      formTips: ["Tuck pelvis.", "Squeeze glutes."],
      alternatives: ["Side Plank", "Ab Wheel Rollout"],
    ),
    ExerciseModel(
      id: "ex_bicep_curl",
      name: "Bicep Curls",
      targetMuscle: "Arms",
      difficulty: "Beginner",
      equipment: "Dumbbell",
      sets: 3,
      reps: "12-15 reps",
      restSeconds: 45,
      caloriesBurned: 70,
      durationMinutes: 12,
      animationType: ExerciseAnimationType.bicepCurl,
      instructions: [
        "Stand tall holding a dumbbell in each hand.",
        "Keep elbows close to your torso.",
        "Curl weights upward while contracting biceps.",
        "Slowly lower back down."
      ],
      commonMistakes: ["Swinging body.", "Drifting elbows forward."],
      formTips: ["Keep shoulders back.", "Focus on bicep isolation."],
      alternatives: ["Hammer Curls", "Cable Curls"],
    ),
    ExerciseModel(
      id: "ex_tricep_pushdown",
      name: "Tricep Pushdowns",
      targetMuscle: "Arms",
      difficulty: "Beginner",
      equipment: "Cable",
      sets: 3,
      reps: "12-15 reps",
      restSeconds: 45,
      caloriesBurned: 70,
      durationMinutes: 10,
      animationType: ExerciseAnimationType.bicepCurl,
      instructions: [
        "Face cable machine, grab attachment with overhand grip.",
        "Keep elbows tucked at sides.",
        "Push down until arms are fully extended.",
        "Slowly return to start."
      ],
      commonMistakes: ["Elbows moving forward.", "Using bodyweight to push."],
      formTips: ["Lock elbows in place.", "Squeeze triceps at bottom."],
      alternatives: ["Overhead Tricep Extension", "Skullcrushers"],
    ),
    ExerciseModel(
      id: "ex_leg_press",
      name: "Leg Press",
      targetMuscle: "Legs",
      difficulty: "Beginner",
      equipment: "Machine",
      sets: 3,
      reps: "10-12 reps",
      restSeconds: 60,
      caloriesBurned: 130,
      durationMinutes: 15,
      animationType: ExerciseAnimationType.squat,
      instructions: [
        "Sit on machine, feet shoulder-width apart on platform.",
        "Lower platform until knees are 90 degrees.",
        "Push platform back up without locking knees."
      ],
      commonMistakes: ["Locking out knees at top.", "Knees caving inward."],
      formTips: ["Drive through heels.", "Control the descent."],
      alternatives: ["Squats", "Lunges"],
    ),
    ExerciseModel(
      id: "ex_romanian_deadlift",
      name: "Romanian Deadlift",
      targetMuscle: "Legs",
      difficulty: "Intermediate",
      equipment: "Barbell",
      sets: 3,
      reps: "10-12 reps",
      restSeconds: 60,
      caloriesBurned: 140,
      durationMinutes: 15,
      animationType: ExerciseAnimationType.deadlift,
      instructions: [
        "Hold barbell at hip level, feet shoulder-width.",
        "Hinge at hips, pushing glutes back.",
        "Lower bar down legs keeping it close.",
        "Drive hips forward to stand."
      ],
      commonMistakes: ["Rounding back.", "Bending knees too much."],
      formTips: ["Feel stretch in hamstrings.", "Keep back flat."],
      alternatives: ["Leg Curl", "Glute Bridge"],
    ),
    ExerciseModel(
      id: "ex_calf_raises",
      name: "Calf Raises",
      targetMuscle: "Legs",
      difficulty: "Beginner",
      equipment: "Bodyweight",
      sets: 3,
      reps: "15-20 reps",
      restSeconds: 45,
      caloriesBurned: 50,
      durationMinutes: 8,
      animationType: ExerciseAnimationType.squat,
      instructions: [
        "Stand on edge of step or flat floor.",
        "Raise heels as high as possible.",
        "Squeeze calves at top.",
        "Lower heels below step level."
      ],
      commonMistakes: ["Bouncing reps.", "Not going full range."],
      formTips: ["Pause at the top.", "Control the negative."],
      alternatives: ["Seated Calf Raise", "Leg Press Calf Raise"],
    )
  ];

  static List<WorkoutCategoryModel> getAllCategories() {
    return [
      _createCategory("cat_fullbody", "Full Body", "Total body compound session", Icons.bolt_rounded, [const Color(0xFFFFB300), const Color(0xFFFF6F00)], ["ex_squat", "ex_pushup", "ex_pullup", "ex_shoulder_press", "ex_plank"]),
      _createCategory("cat_chest", "Chest", "Target upper, lower, and mid pectorals", Icons.fitness_center_rounded, [const Color(0xFFE53935), const Color(0xFF880E4F)], ["ex_bench_press", "ex_pushup"]),
      _createCategory("cat_back", "Back", "Build a wide V-taper and thickness", Icons.accessibility_rounded, [const Color(0xFF1E88E5), const Color(0xFF0D47A1)], ["ex_deadlift", "ex_pullup", "ex_lat_pulldown", "ex_dumbbell_row"]),
      _createCategory("cat_legs", "Legs", "Build massive quad and hamstring power", Icons.directions_run_rounded, [const Color(0xFF43A047), const Color(0xFF1B5E20)], ["ex_squat", "ex_leg_press", "ex_romanian_deadlift", "ex_lunges", "ex_calf_raises"]),
      _createCategory("cat_shoulders", "Shoulders", "Sculpt 3D deltoids", Icons.hardware_rounded, [const Color(0xFFFB8C00), const Color(0xFFE65100)], ["ex_shoulder_press"]),
      _createCategory("cat_arms", "Arms", "Biceps and triceps isolation", Icons.sports_gymnastics_rounded, [const Color(0xFF8E24AA), const Color(0xFF4A148C)], ["ex_bicep_curl", "ex_tricep_pushdown"]),
      _createCategory("cat_abs", "Abs & Core", "Shred your midsection and stability", Icons.shield_rounded, [const Color(0xFF8E24AA), const Color(0xFF4A148C)], ["ex_plank"]),
      _createCategory("cat_fatloss", "Fat Loss", "High calorie burn resistance combo", Icons.local_fire_department, [const Color(0xFFFF3D00), const Color(0xFFDD2C00)], ["ex_lunges", "ex_pushup", "ex_squat", "ex_plank"]),
      _createCategory("cat_musclegain", "Muscle Gain", "Maximum hypertrophy stimulus", Icons.trending_up_rounded, [const Color(0xFF00E676), const Color(0xFF00A152)], ["ex_bench_press", "ex_squat", "ex_deadlift", "ex_pullup"]),
      _createCategory("cat_strength", "Strength Training", "Heavy weight low rep progression", Icons.fitness_center_outlined, [const Color(0xFF26A69A), const Color(0xFF004D40)], ["ex_deadlift", "ex_squat", "ex_bench_press", "ex_shoulder_press"]),
      _createCategory("cat_home", "Home Workouts", "No equipment bodyweight routines", Icons.home_rounded, [const Color(0xFF00ACC1), const Color(0xFF00838F)], ["ex_pushup", "ex_lunges", "ex_plank"]),
      _createCategory("cat_gym", "Gym Workouts", "Full iron setup routines", Icons.fitness_center_rounded, [const Color(0xFF7E57C2), const Color(0xFF512DA8)], ["ex_bench_press", "ex_squat", "ex_deadlift", "ex_lat_pulldown", "ex_leg_press"]),
    ];
  }

  static WorkoutCategoryModel _createCategory(String id, String title, String desc, IconData icon, List<Color> colors, List<String> exerciseIds) {
    List<ExerciseModel> exercises = [];
    for (var eid in exerciseIds) {
      try {
        exercises.add(sampleExercises.firstWhere((e) => e.id == eid));
      } catch (e) {
        // Skip if not found
      }
    }
    return WorkoutCategoryModel(
      id: id,
      title: title,
      description: desc,
      icon: icon,
      gradientColors: colors,
      badgeText: exercises.length.toString() + " EXERCISES",
      level: "All Levels",
      exercises: exercises,
    );
  }

  // Auto-generate a highly personalized workout based on user profile
  static WorkoutCategoryModel generatePersonalizedWorkout(FitnessProvider provider) {
    List<ExerciseModel> chosenExercises = [];
    
    // Logic: Select exercises based on Location, Level, and Goal
    if (provider.workoutLocation == "Home") {
      chosenExercises = sampleExercises.where((e) => e.equipment == "Bodyweight").toList();
    } else {
      chosenExercises = List.from(sampleExercises); // Give full access if in Gym
      // Prioritize compound movements for Muscle Gain / Strength
      if (provider.fitnessGoal == "Muscle Gain" || provider.fitnessGoal == "Strength") {
        chosenExercises.sort((a, b) => b.caloriesBurned.compareTo(a.caloriesBurned));
      }
    }

    // Adjust Intensity based on Fitness Level
    List<ExerciseModel> tailoredExercises = chosenExercises.take(provider.workoutDuration ~/ 10).map((ex) {
      int adjustedSets = ex.sets;
      String adjustedReps = ex.reps;
      int adjustedRest = ex.restSeconds;

      if (provider.fitnessLevel == "Beginner") {
        adjustedSets = (ex.sets - 1).clamp(2, 5);
        adjustedReps = "12-15 reps"; // Higher reps, lower weight for beginners
        adjustedRest = ex.restSeconds + 30; // More rest
      } else if (provider.fitnessLevel == "Advanced") {
        adjustedSets = ex.sets + 1;
        adjustedReps = provider.fitnessGoal == "Strength" ? "4-6 reps" : "8-12 reps";
        adjustedRest = provider.fitnessGoal == "Strength" ? 120 : 60;
      } else { // Intermediate
        adjustedReps = provider.fitnessGoal == "Strength" ? "6-8 reps" : "10-12 reps";
      }

      // Special case for Fat Loss: Less rest, more reps
      if (provider.fitnessGoal == "Fat Loss") {
        adjustedReps = "15-20 reps";
        adjustedRest = 45;
      }

      return ExerciseModel(
        id: ex.id,
        name: ex.name,
        targetMuscle: ex.targetMuscle,
        difficulty: provider.fitnessLevel, // Tailored
        equipment: ex.equipment,
        sets: adjustedSets,
        reps: adjustedReps,
        restSeconds: adjustedRest,
        caloriesBurned: ex.caloriesBurned,
        durationMinutes: ex.durationMinutes,
        animationType: ex.animationType,
        instructions: ex.instructions,
        commonMistakes: ex.commonMistakes,
        formTips: ex.formTips,
        alternatives: ex.alternatives,
      );
    }).toList();

    return WorkoutCategoryModel(
      id: "cat_personalized",
      title: "Your Personalized Plan",
      description: "${provider.fitnessLevel} • ${provider.workoutLocation} • ${provider.fitnessGoal}",
      icon: Icons.auto_awesome_rounded,
      gradientColors: [const Color(0xFF6200EA), const Color(0xFF311B92)],
      badgeText: "AI GENERATED",
      level: provider.fitnessLevel,
      exercises: tailoredExercises,
    );
  }
}
