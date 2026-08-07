import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import '../../core/widgets/soft_card.dart';
import '../profile/profile_screen.dart';
import '../profile/settings_screen.dart';
import '../activity/activity_screen.dart';
import '../gamification/achievements_screen.dart';
import '../workouts/form_analysis_screen.dart';
import '../workouts/smart_generator_dialog.dart';
import 'recovery_score_card.dart';
import 'weather_workout_widget.dart';

import 'dart:math' as math;
import 'package:confetti/confetti.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  FitnessProvider? _provider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newProvider = Provider.of<FitnessProvider>(context);
    if (_provider != newProvider) {
      if (_provider != null) {
        _provider!.removeListener(_checkGoalReached);
      }
      _provider = newProvider;
      _provider!.addListener(_checkGoalReached);
    }
  }

  void _checkGoalReached() {
    if (_provider == null) return;
    if (_provider!.todaySteps >= _provider!.stepGoal && !_provider!.hasShownGoalAnimation) {
      _provider!.markGoalAnimationShown();
      _showGoalAchievedDialog();
    }
  }

  void _showGoalAchievedDialog() {
    final dialogConfetti = ConfettiController(duration: const Duration(seconds: 4));
    dialogConfetti.play();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Goal Achieved",
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                contentPadding: EdgeInsets.zero,
                content: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: FitzaTheme.primaryDark,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events, size: 80, color: Colors.white),
                      const SizedBox(height: 16),
                      const Text(
                        "Goal Achieved!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "You reached your daily step target. Amazing work!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: FitzaTheme.primaryDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text("Awesome!", style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: dialogConfetti,
                blastDirection: math.pi / 2, // downwards
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.1,
                createParticlePath: drawStar,
              ),
            ),
          ],
        );
      },
    ).then((_) => dialogConfetti.dispose());
  }

  @override
  void dispose() {
    _provider?.removeListener(_checkGoalReached);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<FitnessProvider>(context);

    double stepProgress = provider.todaySteps / provider.stepGoal;
    if (stepProgress > 1.0) stepProgress = 1.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clean Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Hi, ${provider.userName}",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          provider.currentTheme == AppThemeMode.light ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          provider.setTheme(
                            provider.currentTheme == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : Colors.black),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: FitzaTheme.primaryDark.withValues(alpha: 0.1),
                          backgroundImage: provider.profileImagePath != null
                              ? (provider.profileImagePath!.startsWith('http')
                                  ? NetworkImage(provider.profileImagePath!) as ImageProvider
                                  : FileImage(File(provider.profileImagePath!)))
                              : null,
                          child: provider.profileImagePath == null
                              ? Text(
                                  provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : "A",
                                  style: theme.textTheme.titleLarge?.copyWith(color: FitzaTheme.primaryDark),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ).animate().fade().slideY(begin: -0.1),

              const SizedBox(height: 32),

              const SizedBox(height: 16),

              // Feature 2: AI Fitness Coach Personalized Message Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text("🤖", style: TextStyle(fontSize: 24)),
                        SizedBox(width: 8),
                        Text(
                          "AI FITNESS COACH",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      provider.getAiCoachMessage(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 16),

              // Feature 19 & 21: Recovery Score & Dynamic Weather Suggestions
              const RecoveryScoreCard(),
              const SizedBox(height: 14),
              const WeatherWorkoutWidget(),
              const SizedBox(height: 16),

              // Daily Streak & Achievements Banner
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen()));
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: FitzaTheme.primaryDark,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_fire_department_rounded, color: Colors.amber, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${provider.currentStreak} Day Streak 🔥 • Level ${provider.userLevel} ${provider.levelTitle}",
                              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${provider.userXp} XP • View Badges & Achievements",
                              style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ).animate().fade(duration: 500.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // AI Workout Actions Row (Smart Generator & AI Form Camera Simulation)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(context: context, builder: (_) => const SmartGeneratorDialog());
                      },
                      icon: const Icon(Icons.psychology_rounded, color: Colors.amber),
                      label: const FittedBox(fit: BoxFit.scaleDown, child: Text("Smart Generator")),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const FormAnalysisScreen()));
                      },
                      icon: const Icon(Icons.camera_front_rounded, color: Colors.cyanAccent),
                      label: const FittedBox(fit: BoxFit.scaleDown, child: Text("AI Camera Check")),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Next-Gen Today's Step Progress Tracker
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityScreen()));
                },
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F2FE).withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                    border: Border.all(
                      color: const Color(0xFF00F2FE).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header Title & Live Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.directions_walk_rounded, color: Color(0xFF00F2FE), size: 24),
                              SizedBox(width: 8),
                              Text(
                                "Today's Step Progress",
                                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F2FE).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00F2FE),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "${((provider.todaySteps / (provider.stepGoal > 0 ? provider.stepGoal : 1)) * 100).clamp(0, 100).toInt()}% Done",
                                  style: const TextStyle(color: Color(0xFF00F2FE), fontSize: 11, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Central Glowing Cyber Gauge Ring & Counter
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: provider.todaySteps),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeOutExpo,
                        builder: (context, animatedSteps, child) {
                          double animatedProgress = provider.stepGoal > 0 ? animatedSteps / provider.stepGoal : 0;
                          if (animatedProgress > 1.0) animatedProgress = 1.0;

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 230,
                                height: 230,
                                child: CustomPaint(
                                  painter: _GaugePainter(progress: animatedProgress),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.directions_run_rounded, color: Color(0xFF00F2FE), size: 36)
                                      .animate(onPlay: (controller) => controller.repeat())
                                      .shimmer(duration: 1500.ms, color: Colors.white)
                                      .animate()
                                      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 800.ms, curve: Curves.easeInOut),
                                  const SizedBox(height: 2),
                                  Text(
                                    "$animatedSteps",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 46,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  Text(
                                    "Target: ${provider.stepGoal} steps",
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 14),

                                  // Increment / Decrement Controls
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => provider.removeStepGoal(500),
                                        icon: const Icon(Icons.remove_circle_outline_rounded),
                                        color: Colors.white70,
                                        iconSize: 28,
                                        tooltip: "-500 Steps",
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          "±500",
                                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () => provider.addStepGoal(500),
                                        icon: const Icon(Icons.add_circle_outline_rounded),
                                        color: const Color(0xFF00F2FE),
                                        iconSize: 28,
                                        tooltip: "+500 Steps",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // 3-Column Modern Metric Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInnerMetric("Distance", "${provider.distanceWalked.toStringAsFixed(2)} km", Icons.map_rounded, Colors.blueAccent),
                          _buildInnerMetric("Active Time", "${provider.activeMinutes} min", Icons.timer_rounded, Colors.purpleAccent),
                          _buildInnerMetric("Calories", "${provider.caloriesBurned} kcal", Icons.local_fire_department_rounded, Colors.deepOrange),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fade(duration: 500.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),
              
              const SizedBox(height: 24),
              
              // Water Tracker Interactive Widget
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF), // Bright solid blue
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Daily Hydration",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${provider.waterIntake} / 8 Glasses",
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            provider.removeWaterGlass();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.remove, color: Colors.white, size: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {
                            provider.addWaterGlass();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 28),
                          ).animate(key: ValueKey(provider.waterIntake)).scaleXY(begin: 0.8, end: 1.2, duration: 200.ms).then().scaleXY(begin: 1.2, end: 1, duration: 200.ms),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fade(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOut),
              
              const SizedBox(height: 24),



              // Active Workout Tracker Simulation Panel
              SoftCard(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Live Activity Tracking",
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (provider.isTrackingActivity)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text("LIVE", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (!provider.isTrackingActivity) ...[
                      Text("Choose an activity type to track with GPS & Sensors:", style: theme.textTheme.labelMedium),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.start,
                        children: ["Walking", "Running", "Cycling"].map((type) {
                          IconData icon = Icons.directions_walk_rounded;
                          if (type == "Running") icon = Icons.directions_run_rounded;
                          if (type == "Cycling") icon = Icons.directions_bike_rounded;
                          return ElevatedButton.icon(
                            onPressed: () => provider.startActivity(type),
                            icon: Icon(icon, size: 18),
                            label: Text(type),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FitzaTheme.primaryDark.withValues(alpha: 0.1),
                              foregroundColor: FitzaTheme.primaryDark,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              elevation: 0,
                            ),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(provider.activityType, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                "${(provider.activitySeconds ~/ 60).toString().padLeft(2, '0')}:${(provider.activitySeconds % 60).toString().padLeft(2, '0')}",
                                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Distance: ${provider.activityDistance.toStringAsFixed(2)} km", style: theme.textTheme.labelLarge),
                              const SizedBox(height: 4),
                              Text("Speed: ${provider.activityDistance > 0 ? (provider.activityDistance / (provider.activitySeconds / 3600)).toStringAsFixed(1) : '0'} km/h", style: theme.textTheme.labelLarge),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => provider.stopActivity(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          elevation: 0,
                        ),
                        child: const Text("Stop & Save Workout"),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // BMI Calculator Card
              SoftCard(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Body Mass Index (BMI)",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.bmi.toStringAsFixed(1),
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: provider.bmiColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: provider.bmiColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                provider.bmiCategory,
                                style: TextStyle(
                                  color: provider.bmiColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Height: ${provider.height} cm", style: theme.textTheme.labelLarge),
                            const SizedBox(height: 6),
                            Text("Weight: ${provider.weight} kg", style: theme.textTheme.labelLarge),
                            const SizedBox(height: 6),
                            Text("Age: ${provider.age} yrs", style: theme.textTheme.labelLarge),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // padding for the taskbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInnerMetric(String label, String value, IconData icon, [Color accentColor = const Color(0xFF00F2FE)]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
        ],
      ),
    );
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (3.141592653589793 / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * math.cos(step),
          halfWidth + externalRadius * math.sin(step));
      path.lineTo(halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * math.sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  _GaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 10;
    
    // 260-degree sweep arc from 140 to 40 degrees
    const startAngle = 140 * math.pi / 180;
    const sweepAngle = 260 * math.pi / 180;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track arc
    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);

    // Glowing Neon Gradient Active Arc
    if (progress > 0) {
      final gradient = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + (sweepAngle * progress),
        colors: const [
          Color(0xFF00F2FE), // Electric Cyan
          Color(0xFF4FACFE), // Blue
          Color(0xFF00E676), // Spring Emerald
        ],
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = 18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
