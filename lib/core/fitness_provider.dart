import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitza/core/theme.dart';
import 'package:fitza/core/native_media_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health/health.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

class WeightLog {
  final String id;
  final double weight;
  final DateTime date;
  final String? imagePath;

  WeightLog({
    required this.id,
    required this.weight,
    required this.date,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'weight': weight,
    'date': date.toIso8601String(),
    'imagePath': imagePath,
  };
  
  factory WeightLog.fromJson(Map<String, dynamic> json) => WeightLog(
    id: json['id'],
    weight: json['weight'],
    date: DateTime.parse(json['date']),
    imagePath: json['imagePath'],
  );
}


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
  String? _profileImagePath;
  String? get profileImagePath => _profileImagePath;

  bool _needsDailyStart = false;
  bool get needsDailyStart => _needsDailyStart;

  // --- User Profile ---
  int _age = 26;
  int get age => _age;
  double _height = 178.0; // cm
  double get height => _height;
  double _weight = 74.5; // kg
  double get weight => _weight;
  String _fitnessGoal = "Weight Loss";
  String get fitnessGoal => _fitnessGoal;

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

  // --- Gamification ---
  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  int _userXp = 0;
  int get userXp => _userXp;

  int get userLevel => (_userXp ~/ 1000) + 1;

  String get levelTitle {
    int lvl = userLevel;
    if (lvl < 2) return "Beginner";
    if (lvl < 5) return "Amateur";
    if (lvl < 10) return "Pro";
    if (lvl < 20) return "Athlete";
    return "Elite";
  }

  // --- Wear OS Sync Status ---
  bool _isWearOsSynced = true;
  DateTime _lastWearOsSync = DateTime.now();
  bool get isWearOsSynced => _isWearOsSynced;
  DateTime get lastWearOsSync => _lastWearOsSync;

  // --- Water Intake State ---
  int _waterIntake = 0; // glasses
  int get waterIntake => _waterIntake;

  void addWaterGlass() {
    _waterIntake++;
    _prefs?.setInt('${_userEmail}_waterIntake', _waterIntake);
    notifyListeners();
  }

  void removeWaterGlass() {
    if (_waterIntake > 0) {
      _waterIntake--;
      _prefs?.setInt('${_userEmail}_waterIntake', _waterIntake);
      notifyListeners();
    }
  }

  // --- Advanced Music Player State ---
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  final List<Map<String, String>> _playlist = [
    {
      "title": "Energy Boost (120 BPM)",
      "artist": "Fitza Original",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
    },
    {
      "title": "Running Rhythm",
      "artist": "Fitza Original",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"
    },
    {
      "title": "Cool Down Vibes",
      "artist": "Fitza Original",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3"
    },
    {
      "title": "Heavy Lift Anthem",
      "artist": "Fitza Iron",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3"
    },
    {
      "title": "Cardio Sprint",
      "artist": "Fitza Beat",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3"
    },
    {
      "title": "Meditation Focus",
      "artist": "Fitza Zen",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3"
    }
  ];
  int _currentTrackIndex = 0;

  String? get trackTitle => _playlist[_currentTrackIndex]["title"];
  String? get trackArtist => _playlist[_currentTrackIndex]["artist"];
  List<Map<String, String>> get playlist => _playlist;
  int get currentTrackIndex => _currentTrackIndex;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;
  Duration _totalDuration = Duration.zero;
  Duration get totalDuration => _totalDuration;
  bool _isLooping = false;
  bool get isLooping => _isLooping;
  double _volume = 1.0;
  double get volume => _volume;
  String? _trackApp;
  String? get trackApp => _trackApp;
  double _musicProgress = 0.0;
  double get musicProgress => _musicProgress;

  // --- Settings & AI Logs ---
  bool _pushNotificationsEnabled = true;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;

  bool _autoSyncEnabled = true;
  bool get autoSyncEnabled => _autoSyncEnabled;

  bool _isGoogleFitConnected = false;
  bool get isGoogleFitConnected => _isGoogleFitConnected;
  
  bool _isAppleHealthConnected = false;
  bool get isAppleHealthConnected => _isAppleHealthConnected;
  
  bool _isSamsungHealthConnected = false;
  bool get isSamsungHealthConnected => _isSamsungHealthConnected;

  bool _hasShownGoalAnimation = false;
  bool get hasShownGoalAnimation => _hasShownGoalAnimation;

  String? _geminiApiKey;
  String? get geminiApiKey => _geminiApiKey;
  
  final List<FoodLog> _foodLogs = [];
  List<FoodLog> get foodLogs => _foodLogs;

  List<WeightLog> _weightLogs = [];
  List<WeightLog> get weightLogs => _weightLogs;

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
  List<Position> _activityPath = [];
  List<Position> get activityPath => _activityPath;
  StreamSubscription<Position>? _positionStream;

  Position? _currentLocation;
  Position? get currentLocation => _currentLocation;

  Future<void> fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
    
    _currentLocation = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
    notifyListeners();
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      if (_activityPath.isNotEmpty) {
        double distanceInMeters = Geolocator.distanceBetween(
          _activityPath.last.latitude,
          _activityPath.last.longitude,
          position.latitude,
          position.longitude,
        );
        _activityDistance += distanceInMeters / 1000.0; // convert to km
      }
      _activityPath.add(position);
      notifyListeners();
    });
  }

  StreamSubscription<StepCount>? _stepCountSubscription;
  int _initialSteps = -1;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  FitnessProvider() {
    _initPrefs();
    _initPedometer();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    _updateStepNotification();
  }

  Future<void> _updateStepNotification() async {
    if (!_pushNotificationsEnabled) {
      await _flutterLocalNotificationsPlugin.cancel(888);
      return;
    }
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'step_tracker_channel',
      'Step Tracker',
      channelDescription: 'Ongoing notification showing current step progress',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      enableVibration: false,
      playSound: false,
      icon: '@mipmap/launcher_icon',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _flutterLocalNotificationsPlugin.show(
      888,
      'Steps Today: $_todaySteps / $_stepGoal',
      'Keep moving to reach your daily goal!',
      platformChannelSpecifics,
    );
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isLoggedIn = _prefs?.getBool('isLoggedIn') ?? false;
    _hasCompletedOnboarding = _prefs?.getBool('hasCompletedOnboarding') ?? false;
    _userName = _prefs?.getString('${_userEmail}_userName') ?? _prefs?.getString('userName') ?? "Alex Fit";
    _userEmail = _prefs?.getString('userEmail') ?? "alex.fitza@gmail.com";
    _profileImagePath = _prefs?.getString('${_userEmail}_profileImagePath');
    _age = _prefs?.getInt('${_userEmail}_age') ?? _prefs?.getInt('age') ?? 26;
    _height = _prefs?.getDouble('${_userEmail}_height') ?? _prefs?.getDouble('height') ?? 178.0;
    _weight = _prefs?.getDouble('${_userEmail}_weight') ?? _prefs?.getDouble('weight') ?? 74.5;
    _fitnessGoal = _prefs?.getString('${_userEmail}_fitnessGoal') ?? _prefs?.getString('fitnessGoal') ?? "Weight Loss";
    _stepGoal = _prefs?.getInt('${_userEmail}_stepGoal') ?? _prefs?.getInt('stepGoal') ?? 8000;
    _calorieGoal = _prefs?.getInt('${_userEmail}_calorieGoal') ?? _prefs?.getInt('calorieGoal') ?? 2200;
    _waterGoal = _prefs?.getInt('${_userEmail}_waterGoal') ?? _prefs?.getInt('waterGoal') ?? 8;
    
    _userXp = _prefs?.getInt('${_userEmail}_userXp') ?? 0;
    _currentStreak = _prefs?.getInt('${_userEmail}_currentStreak') ?? 0;
    
    // Check Midnight Reset
    String lastSavedDate = _prefs?.getString('${_userEmail}_lastSavedDate') ?? '';
    String todayStr = DateTime.now().toIso8601String().substring(0, 10);
    
    if (lastSavedDate != todayStr && lastSavedDate.isNotEmpty) {
      // Process yesterday's streak
      int yesterdaySteps = _prefs?.getInt('${_userEmail}_todaySteps') ?? 0;
      if (yesterdaySteps >= _stepGoal) {
        _currentStreak += 1;
      } else {
        _currentStreak = 0;
      }
      _prefs?.setInt('${_userEmail}_currentStreak', _currentStreak);

      _todaySteps = 0;
      _todayWater = 0;
      _prefs?.setInt('${_userEmail}_todaySteps', 0);
      _prefs?.setInt('${_userEmail}_todayWater', 0);
      _prefs?.setString('${_userEmail}_lastSavedDate', todayStr);
      _needsDailyStart = true;
      _hasShownGoalAnimation = false;
    } else if (lastSavedDate != todayStr) {
      // First time saving date
      _todaySteps = 0;
      _todayWater = 0;
      _prefs?.setString('${_userEmail}_lastSavedDate', todayStr);
    } else {
      _todaySteps = _prefs?.getInt('${_userEmail}_todaySteps') ?? _prefs?.getInt('todaySteps') ?? 3450;
      _todayWater = _prefs?.getInt('${_userEmail}_todayWater') ?? _prefs?.getInt('todayWater') ?? 3;
      _hasShownGoalAnimation = _prefs?.getBool('${_userEmail}_hasShownGoalAnim') ?? false;
    }
    
    _isGoogleFitConnected = _prefs?.getBool('${_userEmail}_isGoogleFitConnected') ?? false;
    _isAppleHealthConnected = _prefs?.getBool('${_userEmail}_isAppleHealthConnected') ?? false;
    _isSamsungHealthConnected = _prefs?.getBool('${_userEmail}_isSamsungHealthConnected') ?? false;
    _waterIntake = _prefs?.getInt('${_userEmail}_waterIntake') ?? 0;
    
    final _weightHistory = _prefs?.getString('${_userEmail}_weightHistory') ?? _prefs?.getString('weightHistory') ?? '';
    _pushNotificationsEnabled = _prefs?.getBool('pushNotifications') ?? true;
    _autoSyncEnabled = _prefs?.getBool('autoSync') ?? true;

    if (_weightHistory.isNotEmpty) {
      final List decoded = jsonDecode(_weightHistory);
      _weightLogs = decoded.map((e) => WeightLog.fromJson(e)).toList();
    } else {
      _weightLogs = [
        WeightLog(id: "1", weight: 75.8, date: DateTime.now().subtract(const Duration(days: 21))),
        WeightLog(id: "2", weight: 75.2, date: DateTime.now().subtract(const Duration(days: 14))),
        WeightLog(id: "3", weight: 74.8, date: DateTime.now().subtract(const Duration(days: 7))),
      ];
    }
    
    final themeIndex = _prefs?.getInt('themeMode') ?? 1; // Default dark
    if (themeIndex >= 0 && themeIndex < AppThemeMode.values.length) {
      _currentTheme = AppThemeMode.values[themeIndex];
    }
    
    _geminiApiKey = _prefs?.getString('geminiApiKey');
    
    _initAudioPlayer();
    notifyListeners();
  }

  void _initAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    _audioPlayer.onPositionChanged.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });
    _audioPlayer.onDurationChanged.listen((dur) {
      _totalDuration = dur;
      notifyListeners();
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (!_isLooping) {
        nextMusic();
      }
    });
    _audioPlayer.setSourceUrl(_playlist[_currentTrackIndex]["url"]!);
  }

  Future<void> playPauseMusic() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(_playlist[_currentTrackIndex]["url"]!));
    }
  }

  Future<void> nextMusic() async {
    _currentTrackIndex = (_currentTrackIndex + 1) % _playlist.length;
    await _audioPlayer.play(UrlSource(_playlist[_currentTrackIndex]["url"]!));
    notifyListeners();
  }

  Future<void> prevMusic() async {
    _currentTrackIndex = (_currentTrackIndex - 1) < 0 ? _playlist.length - 1 : (_currentTrackIndex - 1);
    await _audioPlayer.play(UrlSource(_playlist[_currentTrackIndex]["url"]!));
    notifyListeners();
  }

  Future<void> playTrackAtIndex(int index) async {
    _currentTrackIndex = index;
    await _audioPlayer.play(UrlSource(_playlist[_currentTrackIndex]["url"]!));
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double vol) async {
    _volume = vol;
    await _audioPlayer.setVolume(vol);
    notifyListeners();
  }

  Future<void> toggleLoop() async {
    _isLooping = !_isLooping;
    await _audioPlayer.setReleaseMode(_isLooping ? ReleaseMode.loop : ReleaseMode.release);
    notifyListeners();
  }

  void setTheme(AppThemeMode mode) {
    _currentTheme = mode;
    _prefs?.setInt('themeMode', mode.index);
    notifyListeners();
  }

  // --- Auth Actions ---
  Future<void> loginWithGoogle(String mockName, String mockEmail) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        _isLoggedIn = true;
        _userName = account.displayName ?? mockName;
        _userEmail = account.email;
        await _prefs?.setBool('isLoggedIn', true);
        await _prefs?.setString('userName', _userName);
        await _prefs?.setString('userEmail', _userEmail);
        await _initPrefs();
        notifyListeners();
      }
    } catch (error) {
      debugPrint("Google Sign In failed: $error. Falling back to mock login for testing.");
      _isLoggedIn = true;
      _userName = mockName;
      _userEmail = mockEmail;
      await _prefs?.setBool('isLoggedIn', true);
      await _prefs?.setString('userName', _userName);
      await _prefs?.setString('userEmail', _userEmail);
      await _initPrefs();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await _prefs?.setBool('isLoggedIn', false);
    notifyListeners();
  }

  // --- Profile Actions ---
  Future<void> setGeminiApiKey(String key) async {
    _geminiApiKey = key;
    await _prefs?.setString('geminiApiKey', key);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required int age,
    required double height,
    required double weight,
    String? phone,
    String? country,
    String? state,
    String? fitnessGoal,
  }) async {
    _userName = name;
    _age = age;
    _height = height;
    _weight = weight;
    if (fitnessGoal != null) _fitnessGoal = fitnessGoal;
    await _prefs?.setString('${_userEmail}_userName', name);
    await _prefs?.setInt('${_userEmail}_age', age);
    await _prefs?.setDouble('${_userEmail}_height', height);
    await _prefs?.setDouble('${_userEmail}_weight', weight);
    if (phone != null) await _prefs?.setString('${_userEmail}_phone', phone);
    if (country != null) await _prefs?.setString('${_userEmail}_country', country);
    if (state != null) await _prefs?.setString('${_userEmail}_state', state);
    if (fitnessGoal != null) await _prefs?.setString('${_userEmail}_fitnessGoal', fitnessGoal);
    notifyListeners();
  }

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    _prefs?.setBool('hasCompletedOnboarding', true);
    notifyListeners();
  }

  void setDailyStartCompleted() {
    _needsDailyStart = false;
    notifyListeners();
  }

  void updateProfilePicture(String path) {
    _profileImagePath = path;
    _prefs?.setString('${_userEmail}_profileImagePath', path);
    notifyListeners();
  }

  // --- Goals Updates ---
  Future<void> updateGoals({int? steps, int? calories, int? water}) async {
    if (steps != null) {
      _stepGoal = steps;
      await _prefs?.setInt('${_userEmail}_stepGoal', steps);
    }
    if (calories != null) {
      _calorieGoal = calories;
      await _prefs?.setInt('${_userEmail}_calorieGoal', calories);
    }
    if (water != null) {
      _waterGoal = water;
      await _prefs?.setInt('${_userEmail}_waterGoal', water);
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

  // --- Real Pedometer Setup ---
  void _initPedometer() async {
    // Request permission on Android (iOS handles this natively)
    if (await Permission.activityRecognition.request().isGranted) {
      _stepCountSubscription = Pedometer.stepCountStream.listen(_onStepCount, onError: _onStepCountError);
    }
  }

  void _onStepCount(StepCount event) {
    if (_initialSteps == -1) {
      _initialSteps = event.steps - _todaySteps;
      if (_initialSteps < 0) _initialSteps = 0; // fallback
    }
    int newSteps = event.steps - _initialSteps;
    if (newSteps > _todaySteps) {
      _userXp += (newSteps - _todaySteps); // 1 XP per step
      _prefs?.setInt('${_userEmail}_userXp', _userXp);
    }
    _todaySteps = newSteps;
    _prefs?.setInt('todaySteps', _todaySteps);
    _prefs?.setInt('${_userEmail}_todaySteps', _todaySteps);
    _updateStepNotification();
    notifyListeners();
  }

  void _onStepCountError(error) {
    debugPrint("Pedometer Error: $error");
  }

  // --- Manual/Mock Controls for Testing ---
  void addSteps(int count) {
    _todaySteps += count;
    _userXp += count; // 1 XP per step manually added
    _prefs?.setInt('todaySteps', _todaySteps);
    _prefs?.setInt('${_userEmail}_todaySteps', _todaySteps);
    _prefs?.setInt('${_userEmail}_userXp', _userXp);
    _updateStepNotification();
    notifyListeners();
  }

  void removeSteps(int steps) {
    if (_todaySteps - steps >= 0) {
      _todaySteps -= steps;
    } else {
      _todaySteps = 0;
    }
    _prefs?.setInt('todaySteps', _todaySteps);
    _prefs?.setInt('${_userEmail}_todaySteps', _todaySteps);
    _updateStepNotification();
    notifyListeners();
  }

  void addStepGoal(int amount) {
    _stepGoal += amount;
    _prefs?.setInt('stepGoal', _stepGoal);
    _prefs?.setInt('${_userEmail}_stepGoal', _stepGoal);
    notifyListeners();
  }

  void removeStepGoal(int amount) {
    if (_stepGoal - amount >= 1000) {
      _stepGoal -= amount;
    } else {
      _stepGoal = 1000; // Minimum goal
    }
    _prefs?.setInt('stepGoal', _stepGoal);
    _prefs?.setInt('${_userEmail}_stepGoal', _stepGoal);
    notifyListeners();
  }

  void setPushNotifications(bool value) {
    _pushNotificationsEnabled = value;
    _prefs?.setBool('pushNotifications', value);
    notifyListeners();
  }

  void setAutoSync(bool value) {
    _autoSyncEnabled = value;
    _prefs?.setBool('autoSync', value);
    notifyListeners();
  }

  void addWater() {
    if (_todayWater < _waterGoal * 2) {
      _todayWater++;
      _prefs?.setInt('todayWater', _todayWater);
      _prefs?.setInt('${_userEmail}_todayWater', _todayWater);
      notifyListeners();
    }
  }

  void resetTodayMetrics() {
    _todaySteps = 0;
    _todayWater = 0;
    _prefs?.setInt('todaySteps', 0);
    _prefs?.setInt('todayWater', 0);
    _prefs?.setInt('${_userEmail}_todaySteps', 0);
    _prefs?.setInt('${_userEmail}_todayWater', 0);
    _hasShownGoalAnimation = false;
    _prefs?.setBool('${_userEmail}_hasShownGoalAnim', false);
    _foodLogs.clear();
    notifyListeners();
  }

  // --- Wear OS Sync ---
  Future<void> syncWithWearOS() async {
    _isWearOsSynced = false;
    notifyListeners();
    
    final health = Health();
    // Simulated sync delay
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    
    // Simulate getting 500 steps from watch
    int? steps = 500 + _todaySteps;
    if (steps != null) {
      _todaySteps = steps;
      _prefs?.setInt('todaySteps', _todaySteps);
      _prefs?.setInt('${_userEmail}_todaySteps', _todaySteps);
    }
    _isWearOsSynced = true;
    _lastWearOsSync = now;
    notifyListeners();
  }

  // --- Health App Integrations ---
  Future<bool> connectGoogleFit() async {
    _isGoogleFitConnected = true;
    await _prefs?.setBool('isGoogleFitConnected', true);
    notifyListeners();
    return true;
  }

  Future<void> disconnectGoogleFit() async {
    _isGoogleFitConnected = false;
    await _prefs?.setBool('isGoogleFitConnected', false);
    notifyListeners();
  }

  Future<bool> connectAppleHealth() async {
    _isAppleHealthConnected = true;
    await _prefs?.setBool('isAppleHealthConnected', true);
    notifyListeners();
    return true;
  }

  Future<void> disconnectAppleHealth() async {
    _isAppleHealthConnected = false;
    await _prefs?.setBool('isAppleHealthConnected', false);
    notifyListeners();
  }

  Future<bool> connectSamsungHealth() async {
    _isSamsungHealthConnected = true;
    await _prefs?.setBool('${_userEmail}_isSamsungHealthConnected', true);
    notifyListeners();
    return true;
  }

  Future<void> disconnectSamsungHealth() async {
    _isSamsungHealthConnected = false;
    await _prefs?.setBool('${_userEmail}_isSamsungHealthConnected', false);
    notifyListeners();
  }

  void markGoalAnimationShown() {
    _hasShownGoalAnimation = true;
    _prefs?.setBool('${_userEmail}_hasShownGoalAnim', true);
    // Don't notifyListeners here to avoid rebuild loops during animations
  }



  // --- Activity Tracker (Walking/Running/Cycling) ---
  void startActivity(String type) {
    _activityType = type;
    _isTrackingActivity = true;
    _activitySeconds = 0;
    _activityDistance = 0.0;
    _activityPath = [];
    _activityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _activitySeconds++;
      notifyListeners();
    });
    _startLocationTracking();
    notifyListeners();
  }

  void stopActivity() {
    _isTrackingActivity = false;
    _activityTimer?.cancel();
    _positionStream?.cancel();
    // Add steps from tracking activity to daily totals


    int extraSteps = (_activityDistance * 1300).round();
    _todaySteps += extraSteps;
    _prefs?.setInt('todaySteps', _todaySteps);

    notifyListeners();
  }

  void resetActivity() {
    _isTrackingActivity = false;
    _activityTimer?.cancel();
    _positionStream?.cancel();
    _activitySeconds = 0;
    _activityDistance = 0.0;
    _activityPath = [];
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

  void logWeight(double newWeight, {String? imagePath}) {
    final log = WeightLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weight: newWeight,
      date: DateTime.now(),
      imagePath: imagePath,
    );
    _weightLogs.add(log);
    _weight = newWeight;
    _prefs?.setDouble('weight', newWeight);
    _prefs?.setString('weightHistory', jsonEncode(_weightLogs.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    _activityTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
}
