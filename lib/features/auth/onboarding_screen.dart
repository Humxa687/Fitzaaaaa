import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Onboarding Selection State
  String _selectedGender = "Male";
  int _selectedAge = 26;
  
  // Height State
  bool _isHeightCm = true; 
  double _heightCm = 175.0; 
  int _heightFt = 5;
  int _heightInches = 9;

  // Weight State
  bool _isWeightKg = true; 
  int _weightKg = 72; // Make it int for picker
  int _weightLbs = 158; 

  // Goals & Activity & New Profile Fields
  String _selectedGoal = "Muscle Gain";
  String _selectedActivity = "Moderately Active";
  String _selectedFitnessLevel = "Beginner";
  String _selectedWorkoutLocation = "Home";
  int _selectedWorkoutDays = 3;
  int _selectedWorkoutDuration = 45;
  int _selectedStepGoal = 8000;

  final List<String> _goals = [
    "Muscle Gain",
    "Fat Loss",
    "Strength",
    "Endurance",
    "General Fitness"
  ];

  final List<String> _fitnessLevels = ["Beginner", "Intermediate", "Advanced"];
  final List<String> _workoutLocations = ["Home", "Gym"];
  final List<int> _workoutDurations = [30, 45, 60, 90];
  
  final List<Map<String, String>> _activityLevels = [
    {"title": "Sedentary", "desc": "Little to no exercise, desk job"},
    {"title": "Lightly Active", "desc": "Light exercise 1-3 days/week"},
    {"title": "Moderately Active", "desc": "Moderate exercise 3-5 days/week"},
    {"title": "Very Active", "desc": "Hard exercise 6-7 days/week"},
    {"title": "Athlete", "desc": "Intense physical training daily"},
  ];

  Future<void> _requestPermissions() async {
    await [
      Permission.activityRecognition,
      Permission.location,
    ].request();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _submitProfile();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitProfile() async {
    final provider = Provider.of<FitnessProvider>(context, listen: false);

    double finalHeight = _isHeightCm ? _heightCm : ((_heightFt * 30.48) + (_heightInches * 2.54));
    double finalWeight = _isWeightKg ? _weightKg.toDouble() : (_weightLbs / 2.20462);

    await provider.updateProfile(
      name: provider.userName,
      age: _selectedAge,
      height: double.parse(finalHeight.toStringAsFixed(1)),
      weight: double.parse(finalWeight.toStringAsFixed(1)),
      gender: _selectedGender,
      activityLevel: _selectedActivity,
      heightUnit: _isHeightCm ? "cm" : "ft/in",
      weightUnit: _isWeightKg ? "kg" : "lbs",
      fitnessGoal: _selectedGoal,
      fitnessLevel: _selectedFitnessLevel,
      workoutLocation: _selectedWorkoutLocation,
      workoutDays: _selectedWorkoutDays,
      workoutDuration: _selectedWorkoutDuration,
      stepGoal: _selectedStepGoal,
    );

    await _requestPermissions();
    provider.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<FitnessProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Step Progress Indicator (Step 1 of 4)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: _prevStep,
                    )
                  else
                    const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "STEP ${_currentStep + 1} OF 5",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_currentStep + 1) / 5.0,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            color: Colors.blue.shade600,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) => setState(() => _currentStep = idx),
                children: [
                  _buildGenderAgeStep(theme, provider),
                  _buildHeightWeightStep(theme),
                  _buildGoalsFitnessLevelStep(theme),
                  _buildAvailabilityStep(theme),
                  _buildStepGoalStep(theme),
                ],
              ),
            ),

            // Bottom Navigation Next Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStep == 4 ? "Complete & Start Fitza 🚀" : "Continue",
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Step 1: Gender & Age ---
  Widget _buildGenderAgeStep(ThemeData theme, FitnessProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome, Let's Setup Your Profile 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("Pre-filled from ${provider.userEmail}", style: const TextStyle(color: Colors.grey, fontSize: 13)),

          const SizedBox(height: 32),

          const Text("Select Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildGenderCard("Male", "👨", theme),
              const SizedBox(width: 12),
              _buildGenderCard("Female", "👩", theme),
              const SizedBox(width: 12),
              _buildGenderCard("Other", "👤", theme),
            ],
          ),

          const SizedBox(height: 36),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Select Your Age", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("$_selectedAge Years Old", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade600)),
            ],
          ),
          const SizedBox(height: 12),

          // Premium Cupertino Picker for Age
          SizedBox(
            height: 180,
            child: CupertinoPicker(
              itemExtent: 50,
              diameterRatio: 1.2,
              scrollController: FixedExtentScrollController(initialItem: _selectedAge - 10),
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: Colors.blue.shade600.withOpacity(0.1)),
              onSelectedItemChanged: (index) {
                setState(() => _selectedAge = 10 + index);
              },
              children: List.generate(91, (index) {
                final age = 10 + index;
                final isSelected = age == _selectedAge;
                return Center(
                  child: Text(
                    "$age",
                    style: TextStyle(
                      fontSize: isSelected ? 28 : 22,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                      color: isSelected ? Colors.blue.shade600 : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildGenderCard(String label, String emoji, ThemeData theme) {
    final isSel = _selectedGender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSel ? Colors.blue.shade600.withValues(alpha: 0.15) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSel ? Colors.blue.shade600 : theme.colorScheme.primary.withValues(alpha: 0.15),
              width: isSel ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSel ? Colors.blue.shade600 : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Step 2: Height & Weight ---
  Widget _buildHeightWeightStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Height & Weight 📏", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Used to compute precise BMI and calorie burn.", style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 24),

          // Height Section
          const Text("Your Height", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Center(
            child: _buildUnitToggle(
              "cm", "ft/in", _isHeightCm,
              (v) => setState(() => _isHeightCm = v),
              theme
            ),
          ),
          const SizedBox(height: 20),

          if (_isHeightCm) ...[
            Center(
              child: Text(
                "${_heightCm.round()} cm",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.blue.shade600),
              ),
            ),
            Slider(
              value: _heightCm,
              min: 100,
              max: 250,
              divisions: 150,
              activeColor: Colors.blue.shade600,
              onChanged: (val) => setState(() => _heightCm = val),
            ),
          ] else ...[
            Center(
              child: Text(
                "$_heightFt' $_heightInches\"",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.blue.shade600),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _heightFt.toDouble(),
                    min: 3,
                    max: 8,
                    divisions: 5,
                    activeColor: Colors.blue.shade600,
                    onChanged: (val) => setState(() => _heightFt = val.round()),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _heightInches.toDouble(),
                    min: 0,
                    max: 11,
                    divisions: 11,
                    activeColor: Colors.blue.shade600,
                    onChanged: (val) => setState(() => _heightInches = val.round()),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 36),

          // Weight Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Your Weight", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildUnitToggle(
                "kg", "lbs", _isWeightKg,
                (v) => setState(() => _isWeightKg = v),
                theme
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Premium Cupertino Picker for Weight
          SizedBox(
            height: 180,
            child: CupertinoPicker(
              itemExtent: 50,
              diameterRatio: 1.2,
              scrollController: FixedExtentScrollController(
                initialItem: _isWeightKg ? _weightKg - 30 : _weightLbs - 66
              ),
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: Colors.blue.shade600.withOpacity(0.1)),
              onSelectedItemChanged: (index) {
                setState(() {
                  if (_isWeightKg) {
                    _weightKg = 30 + index;
                  } else {
                    _weightLbs = 66 + index;
                  }
                });
              },
              children: List.generate(_isWeightKg ? 271 : 595, (index) {
                final weight = (_isWeightKg ? 30 : 66) + index;
                final isSelected = weight == (_isWeightKg ? _weightKg : _weightLbs);
                return Center(
                  child: Text(
                    "$weight ${_isWeightKg ? 'kg' : 'lbs'}",
                    style: TextStyle(
                      fontSize: isSelected ? 28 : 22,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                      color: isSelected ? Colors.blue.shade600 : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildUnitToggle(String label1, String label2, bool isLabel1, Function(bool) onChanged, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUnitChip(label1, isLabel1, () => onChanged(true)),
          _buildUnitChip(label2, !isLabel1, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _buildUnitChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Step 3: Goals, Fitness Level & Location ---
  Widget _buildGoalsFitnessLevelStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Personalize Your Plan 🎯", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("We use this to auto-generate your workouts.", style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 24),

          const Text("Primary Fitness Goal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _goals.map((g) {
              final isSel = _selectedGoal == g;
              return ChoiceChip(
                label: Text(g),
                selected: isSel,
                onSelected: (val) => setState(() => _selectedGoal = g),
                selectedColor: Colors.blue.shade600.withOpacity(0.2),
                checkmarkColor: Colors.blue.shade600,
                labelStyle: TextStyle(
                  color: isSel ? Colors.blue.shade600 : theme.colorScheme.onSurface,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          const Text("Current Fitness Level", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fitnessLevels.map((lvl) {
              final isSel = _selectedFitnessLevel == lvl;
              return ChoiceChip(
                label: Text(lvl),
                selected: isSel,
                onSelected: (val) => setState(() => _selectedFitnessLevel = lvl),
                selectedColor: Colors.blue.shade600.withOpacity(0.2),
                checkmarkColor: Colors.blue.shade600,
                labelStyle: TextStyle(
                  color: isSel ? Colors.blue.shade600 : theme.colorScheme.onSurface,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          const Text("Where do you workout?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: _workoutLocations.map((loc) {
              final isSel = _selectedWorkoutLocation == loc;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedWorkoutLocation = loc),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSel ? Colors.blue.shade600.withOpacity(0.15) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSel ? Colors.blue.shade600 : theme.colorScheme.primary.withOpacity(0.15),
                        width: isSel ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(loc == "Home" ? Icons.home_rounded : Icons.fitness_center_rounded, 
                             size: 32, 
                             color: isSel ? Colors.blue.shade600 : Colors.grey),
                        const SizedBox(height: 8),
                        Text(loc, style: TextStyle(fontWeight: FontWeight.bold, color: isSel ? Colors.blue.shade600 : theme.colorScheme.onSurface)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  // --- Step 4: Availability & Activity Level ---
  Widget _buildAvailabilityStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your Availability ⏱️", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Let's build a schedule that works for you.", style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 24),

          const Text("Workout Days per Week", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              int days = index + 1;
              bool isSel = _selectedWorkoutDays == days;
              return GestureDetector(
                onTap: () => setState(() => _selectedWorkoutDays = days),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSel ? Colors.blue.shade600 : theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSel ? Colors.blue.shade600 : Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    "$days",
                    style: TextStyle(
                      color: isSel ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 32),

          const Text("Average Workout Duration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _workoutDurations.map((duration) {
              bool isSel = _selectedWorkoutDuration == duration;
              return ChoiceChip(
                label: Text("$duration min"),
                selected: isSel,
                onSelected: (val) => setState(() => _selectedWorkoutDuration = duration),
                selectedColor: Colors.blue.shade600.withOpacity(0.2),
                checkmarkColor: Colors.blue.shade600,
                labelStyle: TextStyle(
                  color: isSel ? Colors.blue.shade600 : theme.colorScheme.onSurface,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          const Text("Daily Activity Level", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._activityLevels.map((activity) {
            final isSel = _selectedActivity == activity["title"];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedActivity = activity["title"]!),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSel ? Colors.blue.shade600.withValues(alpha: 0.15) : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSel ? Colors.blue.shade600 : theme.colorScheme.primary.withValues(alpha: 0.15),
                      width: isSel ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSel ? Colors.blue.shade600 : Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity["title"]!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSel ? Colors.blue.shade600 : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity["desc"]!,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  // --- Step 5: Step Goal ---
  Widget _buildStepGoalStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Daily Step Goal 🚶", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text("Set your default daily step goal.", style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 40),

          Center(
            child: Text(
              "$_selectedStepGoal",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.blue.shade600,
              ),
            ),
          ),
          const Center(child: Text("Steps/Day", style: TextStyle(fontSize: 16, color: Colors.grey))),

          const SizedBox(height: 40),

          Slider(
            value: _selectedStepGoal.toDouble(),
            min: 1000,
            max: 20000,
            divisions: 38, // 500 step increments
            activeColor: Colors.blue.shade600,
            onChanged: (val) {
              setState(() => _selectedStepGoal = val.round());
            },
          ),
          
          const SizedBox(height: 16),
          const Text(
            "You can always adjust this later from your dashboard.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
