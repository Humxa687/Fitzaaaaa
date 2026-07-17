import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitza/core/theme.dart';
import 'package:fitza/core/native_media_controller.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:notification_listener_service/notification_event.dart';


class FoodLog {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime date;
  final String? imagePath;

  FoodLog({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.date,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'date': date.toIso8601String(),
    'imagePath': imagePath,
  };
}

class FitnessProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  // --- App Theme State ---
  AppThemeMode _currentTheme = AppThemeMode.dark;
  AppThemeMode get currentTheme => _currentTheme;

  // --- Auth State ---
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String _userName = "Alex Fit";
  String get userName => _userName;
  String _userEmail = "alex.fitza@gmail.com";
  String get userEmail => _userEmail;

  // --- User Profile ---
  int _age = 26;
  int get age => _age;
  double _height = 178.0; // cm
  double get height => _height;
  double _weight = 74.5; // kg
  double get weight => _weight;

  // --- Goals & Targets ---
  int _stepGoal = 8000;
  int get stepGoal => _stepGoal;
  int _calorieGoal = 2200;
  int get calorieGoal => _calorieGoal;
  int _waterGoal = 8;
  int get waterGoal => _waterGoal;

  // --- Active Tracker metrics ---
  int _todaySteps = 3450;
  int get todaySteps => _todaySteps;
  int _todayWater = 3;
  int get todayWater => _todayWater;

  // --- Wear OS Sync Status ---
  bool _isWearOsSynced = true;
  DateTime _lastWearOsSync = DateTime.now();
  bool get isWearOsSynced => _isWearOsSynced;
  DateTime get lastWearOsSync => _lastWearOsSync;

  // --- Music Player State ---
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  String _trackTitle = "Sunrise Cardio Beats";
  String get trackTitle => _trackTitle;
  String _trackArtist = "Lofi Fit Crew";
  String get trackArtist => _trackArtist;
  double _musicProgress = 0.35;
  double get musicProgress => _musicProgress;
  Timer? _musicTimer;

  // List of tracks for mock player
  final List<Map<String, String>> _playlist = [
    {"title": "Sunrise Cardio Beats", "artist": "Lofi Fit Crew"},
    {"title": "Ultimate Workout Hits", "artist": "Dua Beats"},
    {"title": "Heavy Lifting Rock", "artist": "Iron Core"},
    {"title": "Deep Focus Yoga Flow", "artist": "Zen Ambient"},
  ];
  int _currentTrackIndex = 0;

  // --- Food AI Logs ---
  List<FoodLog> _foodLogs = [];
  List<FoodLog> get foodLogs => _foodLogs;

  // --- Active Tracking (GPS Simulation) ---
  bool _isTrackingActivity = false;
  bool get isTrackingActivity => _isTrackingActivity;
  String _activityType = "Walking"; // Walking, Running, Cycling
  String get activityType => _activityType;
  int _activitySeconds = 0;
  int get activitySeconds => _activitySeconds;
  double _activityDistance = 0.0; // km
  double get activityDistance => _activityDistance;
  Timer? _activityTimer;

  FitnessProvider() {
    _initPrefs();
    _startStepSimulation();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isLoggedIn = _prefs?.getBool('isLoggedIn') ?? false;
    _hasCompletedOnboarding = _prefs?.getBool('hasCompletedOnboarding') ?? false;
    _userName = _prefs?.getString('userName') ?? "Alex Fit";
    _userEmail = _prefs?.getString('userEmail') ?? "alex.fitza@gmail.com";
    _age = _prefs?.getInt('age') ?? 26;
    _height = _prefs?.getDouble('height') ?? 178.0;
    _weight = _prefs?.getDouble('weight') ?? 74.5;
    _stepGoal = _prefs?.getInt('stepGoal') ?? 8000;
    _calorieGoal = _prefs?.getInt('calorieGoal') ?? 2200;
    _waterGoal = _prefs?.getInt('waterGoal') ?? 8;
    _todaySteps = _prefs?.getInt('todaySteps') ?? 3450;
    _todayWater = _prefs?.getInt('todayWater') ?? 3;
    
    final themeIndex = _prefs?.getInt('themeMode') ?? 1; // Default dark
    if (themeIndex >= 0 && themeIndex < AppThemeMode.values.length) {
      _currentTheme = AppThemeMode.values[themeIndex];
    }
    
    _initMusicListener();
    notifyListeners();
  }

  Future<void> _initMusicListener() async {
    bool isNotificationGranted = await NotificationListenerService.isPermissionGranted();
    if (isNotificationGranted) {
      NotificationListenerService.notificationsStream.listen((event) {
        if (event.packageName.contains("spotify") || event.packageName.contains("music")) {
          if (event.title.isNotEmpty) {
            _trackTitle = event.title;
            _trackArtist = event.content.isNotEmpty ? event.content : "Unknown Artist";
            notifyListeners();
          }
        }
      });
    }
  }

  void setTheme(AppThemeMode mode) {
    _currentTheme = mode;
    _prefs?.setInt('themeMode', mode.index);
    notifyListeners();
  }

  // --- Auth Actions ---
  Future<void> loginWithGoogle(String name, String email) async {
    _isLoggedIn = true;
    _userName = name;
    _userEmail = email;
    await _prefs?.setBool('isLoggedIn', true);
    await _prefs?.setString('userName', name);
    await _prefs?.setString('userEmail', email);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await _prefs?.setBool('isLoggedIn', false);
    notifyListeners();
  }

  // --- Profile Actions ---
  Future<void> updateProfile({required String name, required int age, required double height, required double weight}) async {
    _userName = name;
    _age = age;
    _height = height;
    _weight = weight;
    await _prefs?.setString('userName', name);
    await _prefs?.setInt('age', age);
    await _prefs?.setDouble('height', height);
    await _prefs?.setDouble('weight', weight);
    notifyListeners();
  }

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    _prefs?.setBool('hasCompletedOnboarding', true);
    notifyListeners();
  }

  // --- Goals Updates ---
  Future<void> updateGoals({int? steps, int? calories, int? water}) async {
    if (steps != null) {
      _stepGoal = steps;
      await _prefs?.setInt('stepGoal', steps);
    }
    if (calories != null) {
      _calorieGoal = calories;
      await _prefs?.setInt('calorieGoal', calories);
    }
    if (water != null) {
      _waterGoal = water;
      await _prefs?.setInt('waterGoal', water);
    }
    notifyListeners();
  }

  // --- BMI Calculator ---
  double get bmi {
    double heightInMeters = _height / 100;
    if (heightInMeters == 0) return 0;
    return _weight / (heightInMeters * heightInMeters);
  }

  String get bmiCategory {
    double val = bmi;
    if (val < 18.5) return "Underweight";
    if (val < 25) return "Normal";
    if (val < 30) return "Overweight";
    return "Obese";
  }

  Color get bmiColor {
    double val = bmi;
    if (val < 18.5) return Colors.blue;
    if (val < 25) return Colors.green;
    if (val < 30) return Colors.orange;
    return Colors.red;
  }

  // --- Metric Calculations ---
  double get distanceWalked => _todaySteps * 0.00075; // Average step length
  int get caloriesBurned => (_todaySteps * 0.04).round(); // Calories per step
  int get activeMinutes => (_todaySteps * 0.008).round(); // Active minutes

  int get totalFoodCalories {
    int total = 0;
    for (var log in _foodLogs) {
      if (log.date.day == DateTime.now().day &&
          log.date.month == DateTime.now().month &&
          log.date.year == DateTime.now().year) {
        total += log.calories;
      }
    }
    return total;
  }

  // --- Step Simulation (simulates real-world background movement) ---
  Timer? _stepSimulationTimer;
  void _startStepSimulation() {
    _stepSimulationTimer?.cancel();
    _stepSimulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isLoggedIn) {
        // Increment steps slightly to show real-time live tracking updates
        _todaySteps += (1 + (timer.tick % 3));
        _prefs?.setInt('todaySteps', _todaySteps);
        notifyListeners();
      }
    });
  }

  // --- Manual/Mock Controls for Testing ---
  void addSteps(int count) {
    _todaySteps += count;
    _prefs?.setInt('todaySteps', _todaySteps);
    notifyListeners();
  }

  void addWater() {
    if (_todayWater < _waterGoal * 2) {
      _todayWater++;
      _prefs?.setInt('todayWater', _todayWater);
      notifyListeners();
    }
  }

  void resetTodayMetrics() {
    _todaySteps = 0;
    _todayWater = 0;
    _prefs?.setInt('todaySteps', 0);
    _prefs?.setInt('todayWater', 0);
    _foodLogs.clear();
    notifyListeners();
  }

  // --- Wear OS Sync ---
  void syncWithWearOS() {
    _isWearOsSynced = true;
    _lastWearOsSync = DateTime.now();
    _todaySteps += 350; // Sync steps from watch
    notifyListeners();
  }

  // --- Music Controls ---
  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    NativeMediaController.playPause();
    if (_isPlaying) {
      _musicTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        _musicProgress += 0.01;
        if (_musicProgress >= 1.0) {
          _musicProgress = 0.0;
          nextTrack();
        }
        notifyListeners();
      });
    } else {
      _musicTimer?.cancel();
    }
    notifyListeners();
  }

  void nextTrack() {
    NativeMediaController.next();
    _currentTrackIndex = (_currentTrackIndex + 1) % _playlist.length;
    _trackTitle = _playlist[_currentTrackIndex]["title"]!;
    _trackArtist = _playlist[_currentTrackIndex]["artist"]!;
    _musicProgress = 0.0;
    notifyListeners();
  }

  void prevTrack() {
    NativeMediaController.previous();
    _currentTrackIndex = (_currentTrackIndex - 1 + _playlist.length) % _playlist.length;
    _trackTitle = _playlist[_currentTrackIndex]["title"]!;
    _trackArtist = _playlist[_currentTrackIndex]["artist"]!;
    _musicProgress = 0.0;
    notifyListeners();
  }

  // --- Activity Tracker (Walking/Running/Cycling) ---
  void startActivity(String type) {
    _activityType = type;
    _isTrackingActivity = true;
    _activitySeconds = 0;
    _activityDistance = 0.0;
    _activityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _activitySeconds++;
      // Increment mock distance based on activity type
      double pace = 0.0;
      if (_activityType == "Walking") pace = 0.0015; // km per second
      if (_activityType == "Running") pace = 0.003;
      if (_activityType == "Cycling") pace = 0.005;
      _activityDistance += pace;
      notifyListeners();
    });
    notifyListeners();
  }

  void stopActivity() {
    _isTrackingActivity = false;
    _activityTimer?.cancel();
    // Add steps and calories from tracking activity to daily totals
    int caloriesEarned = 0;
    if (_activityType == "Walking") caloriesEarned = (_activityDistance * 60).round();
    if (_activityType == "Running") caloriesEarned = (_activityDistance * 90).round();
    if (_activityType == "Cycling") caloriesEarned = (_activityDistance * 45).round();

    int extraSteps = (_activityDistance * 1300).round();
    _todaySteps += extraSteps;
    _prefs?.setInt('todaySteps', _todaySteps);

    notifyListeners();
  }

  // --- Food AI Logger ---
  void logFood(String name, int calories, double protein, double carbs, double fat, {String? imagePath}) {
    final log = FoodLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      date: DateTime.now(),
      imagePath: imagePath,
    );
    _foodLogs.insert(0, log);
    notifyListeners();
  }

  @override
  void dispose() {
    _stepSimulationTimer?.cancel();
    _musicTimer?.cancel();
    _activityTimer?.cancel();
    super.dispose();
  }
}
