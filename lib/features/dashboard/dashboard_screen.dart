import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import '../profile/profile_screen.dart';
import '../activity/activity_screen.dart';
import '../gamification/achievements_screen.dart';

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
                    gradient: FitzaTheme.orangeGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 15),
                      )
                    ],
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
                          foregroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
    final provider = Provider.of<FitnessProvider>(context);

    double stepProgress = provider.todaySteps / provider.stepGoal;
    if (stepProgress > 1.0) stepProgress = 1.0;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode Toggle
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Already on Weight Loss mode
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Center(
                            child: Text(
                              "WEIGHT LOSS",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          provider.updateProfile(
                            name: provider.userName,
                            age: provider.age,
                            weight: provider.weight,
                            height: provider.height,
                            fitnessGoal: "Build Muscle",
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              "BODY BUILDING",
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6), 
                                fontWeight: FontWeight.bold, 
                                fontSize: 12
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, ${provider.userName}!",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Your health dashboard for today",
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.brightness_6_outlined),
                            onPressed: () {
                              _showThemeBottomSheet(context, provider);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined),
                            onPressed: () {
                              _showApiKeyDialog(context, provider);
                            },
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                              backgroundImage: provider.profileImagePath != null
                                  ? FileImage(File(provider.profileImagePath!))
                                  : null,
                              child: provider.profileImagePath == null
                                  ? Text(
                                      provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : "A",
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                ],
              ).animate().fade(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut),
              const SizedBox(height: 24),

              // Gamification Banner
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen()));
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.white, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${provider.currentStreak} Day Streak!", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text("Lvl ${provider.userLevel} ${provider.levelTitle}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("${provider.userXp} XP", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 60,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (provider.userXp % 1000) / 1000.0,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fade(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut),
              
              const SizedBox(height: 32),
              // Circular Step Goal Tracker & Live Step Counter
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityScreen()));
                  },
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Today's Step Progress",
                        style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
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
                                width: 240,
                                height: 240,
                                child: CustomPaint(
                                  painter: _GaugePainter(progress: animatedProgress),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.directions_walk, color: Colors.white, size: 40)
                                      .animate(onPlay: (controller) => controller.repeat())
                                      .shimmer(duration: 1200.ms, color: Colors.white54)
                                      .animate()
                                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 600.ms, curve: Curves.easeInOut)
                                      .then()
                                      .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 600.ms, curve: Curves.easeInOut),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$animatedSteps",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 42,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Goal: ${provider.stepGoal}",
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => provider.removeStepGoal(500),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                                      child: const Icon(Icons.remove, color: Colors.white, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                    onTap: () => provider.addStepGoal(500),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInnerMetric("Distance", "${provider.distanceWalked.toStringAsFixed(2)} km", Icons.map),
                          _buildInnerMetric("Active Time", "${provider.activeMinutes} min", Icons.timer),
                          _buildInnerMetric("Calories", "${provider.caloriesBurned} kcal", Icons.local_fire_department),
                        ],
                      ),
                    ],
                  ),
                ),
              )).animate().fade(duration: 500.ms, delay: 200.ms).scaleXY(begin: 0.9, end: 1.0, duration: 500.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              // Water Tracker Interactive Widget
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
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
                            child: const Icon(Icons.remove, color: Colors.white, size: 28),
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
                            child: const Icon(Icons.water_drop, color: Colors.white, size: 32),
                          ).animate(key: ValueKey(provider.waterIntake)).scaleXY(begin: 0.8, end: 1.2, duration: 200.ms).then().scaleXY(begin: 1.2, end: 1, duration: 200.ms),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fade(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOut),
              


              // Active Workout Tracker Simulation Panel
              Card(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
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
                      const SizedBox(height: 16),
                      if (!provider.isTrackingActivity) ...[
                        const Text("Choose an activity type to track with GPS & Sensor simulations:"),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.start,
                          children: ["Walking", "Running", "Cycling"].map((type) {
                            IconData icon = Icons.directions_walk;
                            if (type == "Running") icon = Icons.directions_run;
                            if (type == "Cycling") icon = Icons.directions_bike;
                            return ElevatedButton.icon(
                              onPressed: () => provider.startActivity(type),
                              icon: Icon(icon, size: 16),
                              label: Text(type),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.surface,
                                foregroundColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                Text(provider.activityType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 4),
                                Text(
                                  "${(provider.activitySeconds ~/ 60).toString().padLeft(2, '0')}:${(provider.activitySeconds % 60).toString().padLeft(2, '0')}",
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Distance: ${provider.activityDistance.toStringAsFixed(2)} km"),
                                const SizedBox(height: 4),
                                Text("Speed: ${provider.activityDistance > 0 ? (provider.activityDistance / (provider.activitySeconds / 3600)).toStringAsFixed(1) : '0'} km/h"),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.stopActivity(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                          ),
                          child: const Text("Stop & Save Workout"),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // BMI Calculator Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Body Mass Index (BMI)",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.bmi.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: provider.bmiColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: provider.bmiColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
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
                              Text("Height: ${provider.height} cm"),
                              const SizedBox(height: 4),
                              Text("Weight: ${provider.weight} kg"),
                              const SizedBox(height: 4),
                              Text("Age: ${provider.age} yrs"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100), // padding for the taskbar
            ],
          ),
        ),
      ),
    ],
  ),
);
  }

  Widget _buildInnerMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  void _showThemeBottomSheet(BuildContext context, FitnessProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("App Theme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: AppThemeMode.values.map((mode) {
                  final isSelected = provider.currentTheme == mode;
                  return ChoiceChip(
                    label: Text(mode.name.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        provider.setTheme(mode);
                        Navigator.pop(context);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showApiKeyDialog(BuildContext context, FitnessProvider provider) {
    final TextEditingController controller = TextEditingController(text: provider.geminiApiKey ?? "");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Settings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("General Preferences", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Needs State builder for the dialog to update live
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: const Text("Push Notifications"),
                        subtitle: const Text("Get activity reminders"),
                        value: provider.pushNotificationsEnabled,
                        onChanged: (val) {
                          setDialogState(() {
                            provider.setPushNotifications(val);
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text("Auto-Sync Data"),
                        subtitle: const Text("Sync with Wear OS daily"),
                        value: provider.autoSyncEnabled,
                        onChanged: (val) {
                          setDialogState(() {
                            provider.setAutoSync(val);
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  );
                },
              ),
              const Divider(height: 24),
              const Text("AI Integration", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Enter your Gemini API Key to enable AI features (Food & Weight Scanners).", style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "API Key",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                provider.setGeminiApiKey(controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("API Key Saved!")),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // A custom Path to paint stars
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
    final radius = math.min(size.width / 2, size.height / 2);
    
    // Draw a gauge from 140 degrees to 40 degrees (260 degree sweep)
    const startAngle = 140 * math.pi / 180;
    const sweepAngle = 260 * math.pi / 180;

    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);

    final progressPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
