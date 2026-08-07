import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitza/core/theme.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';
import 'package:health/health.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fitza/core/services/cloud_sync_service.dart';





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

  // --- App Theme State (Sun & Moon Modes Only) ---
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

  bool _isPhoneVerified = false;
  bool get isPhoneVerified => _isPhoneVerified;
  String? _verifiedPhoneNumber;
  String? get verifiedPhoneNumber => _verifiedPhoneNumber;
  String? _generatedOtp;


  bool _needsDailyStart = false;
  bool get needsDailyStart => _needsDailyStart;

  // --- User Profile ---
  String _gender = "Male";
  String get gender => _gender;
  int _age = 26;
  int get age => _age;
  double _height = 178.0; // cm
  double get height => _height;
  double _weight = 74.5; // kg
  double get weight => _weight;
  String _fitnessGoal = "Lose Weight";
  String get fitnessGoal => _fitnessGoal;
  String _activityLevel = "Moderately Active";
  String get activityLevel => _activityLevel;

  String _heightUnit = "cm"; // cm, ft/in
  String get heightUnit => _heightUnit;
  String _weightUnit = "kg"; // kg, lbs
  String get weightUnit => _weightUnit;

  // --- Personalization Additions ---
  String _fitnessLevel = "Beginner";
  String get fitnessLevel => _fitnessLevel;
  String _workoutLocation = "Home";
  String get workoutLocation => _workoutLocation;
  int _workoutDays = 3;
  int get workoutDays => _workoutDays;
  int _workoutDuration = 45;
  int get workoutDuration => _workoutDuration;

  // --- Goals & Targets ---
  int _stepGoal = 8000;
  int get stepGoal => _stepGoal;
  int _calorieGoal = 2200;

  int get calorieGoal => _calorieGoal;
  int _waterGoal = 8;
  int get waterGoal => _waterGoal;

  // --- Smart Calculators ---
  double get bmr {
    double b = (10 * _weight) + (6.25 * _height) - (5 * _age);
    return _gender.toLowerCase() == 'female' ? b - 161 : b + 5;
  }

  double get tdee {
    double multiplier = 1.2;
    switch (_activityLevel) {
      case "Sedentary": multiplier = 1.2; break;
      case "Lightly Active": multiplier = 1.375; break;
      case "Moderately Active": multiplier = 1.55; break;
      case "Very Active": multiplier = 1.725; break;
      case "Athlete": multiplier = 1.9; break;
    }
    return bmr * multiplier;
  }

  int get calculatedWaterGoal {
    // 35ml per kg of body weight
    return (_weight * 0.035 * 4).round(); // ~250ml per glass -> roughly 4 glasses per liter
  }

  // --- Active Tracker metrics ---
  int _todaySteps = 3450;
  int get todaySteps => _todaySteps;
  int _todayWater = 3;
  int get todayWater => _todayWater;

  // --- Gamification & 25 Feature State ---
  int _currentStreak = 12;
  int get currentStreak => _currentStreak;

  int _streakFreezes = 2;
  int get streakFreezes => _streakFreezes;

  int _userXp = 2850;
  int get userXp => _userXp;

  int get userLevel => (_userXp ~/ 1000) + 1;

  String get levelTitle {
    int lvl = userLevel;
    if (lvl <= 5) return "Rookie";
    if (lvl <= 15) return "Athlete";
    if (lvl <= 30) return "Warrior";
    if (lvl <= 50) return "Beast";
    return "Legend";
  }

  int _coins = 480;
  int get coins => _coins;

  // Character Evolution
  String get avatarStage {
    int lvl = userLevel;
    if (lvl < 5) return "Rookie Build";
    if (lvl < 15) return "Athletic Tone";
    if (lvl < 30) return "Defined Warrior";
    if (lvl < 50) return "Beast Physique";
    return "Legendary Titan";
  }

  // Fitness Pet State
  String _petName = "Fitzy";
  String get petName => _petName;
  int _petHealth = 88;
  int get petHealth => _petHealth;
  String _petMood = "Happy";
  String get petMood => _petMood;
  int _petLevel = 4;
  int get petLevel => _petLevel;
  String _petOutfit = "Gym Hoodie";
  String get petOutfit => _petOutfit;

  // Weekly Boss Battle
  String _bossName = "Inferno Dragon";
  String get bossName => _bossName;
  int _bossMaxHp = 1000;
  int get bossMaxHp => _bossMaxHp;
  int _bossCurrentHp = 640;
  int get bossCurrentHp => _bossCurrentHp;

  // Journey Map & Story Mode
  int _currentMapNode = 2; // 0: Village, 1: Forest, 2: Mountain, 3: Temple, 4: Volcano, 5: Arena
  int get currentMapNode => _currentMapNode;
  int _storyChapter = 1;
  int get storyChapter => _storyChapter;
  double _storyProgress = 0.65;
  double get storyProgress => _storyProgress;

  // Readiness / Recovery Score
  int _recoveryScore = 86;
  int get recoveryScore => _recoveryScore;
  double _sleepHours = 7.8;
  double get sleepHours => _sleepHours;
  String _sorenessLevel = "Low";
  String get sorenessLevel => _sorenessLevel;

  // Weather Condition
  String _weatherCondition = "Sunny"; // Sunny, Rainy, Cloudy, Cold
  String get weatherCondition => _weatherCondition;
  int _weatherTemp = 24;
  int get weatherTemp => _weatherTemp;

  // Badges & Shop Items
  final List<String> _unlockedBadges = ['first_workout', 'streak_7', 'calories_5000', 'morning_warrior'];
  List<String> get unlockedBadges => List.unmodifiable(_unlockedBadges);

  final List<String> _ownedShopItems = ['streak_freeze', 'pet_hoodie', 'theme_neon_cyber'];
  List<String> get ownedShopItems => List.unmodifiable(_ownedShopItems);

  // Muscle Heatmap Intensity (0.0 to 1.0)
  Map<String, double> _muscleHeatmap = {
    'Chest': 0.90,
    'Arms': 0.75,
    'Shoulders': 0.65,
    'Abs': 0.50,
    'Back': 0.35,
    'Legs': 0.40,
  };
  Map<String, double> get muscleHeatmap => Map.unmodifiable(_muscleHeatmap);

  // Transformation Photos
  final List<Map<String, String>> _transformationPhotos = [
    {'date': 'Month 1', 'label': 'Initial Starting Point', 'tag': 'Before'},
    {'date': 'Month 3', 'label': 'Muscle Definition & Tone', 'tag': 'Progress'},
    {'date': 'Month 6', 'label': 'Peak Condition', 'tag': 'After'},
  ];
  List<Map<String, String>> get transformationPhotos => List.unmodifiable(_transformationPhotos);

  // --- Wear OS Sync Status ---
  bool _isWearOsSynced = true;
  DateTime _lastWearOsSync = DateTime.now();
  bool get isWearOsSynced => _isWearOsSynced;
  DateTime get lastWearOsSync => _lastWearOsSync;

  // --- Music State ---
  String? _trackTitle = "Fitness Motivation Mix";
  String? _trackArtist = "Fitza Audio";
  String? _trackCoverUrl; // Uses placeholder
  bool _isPlaying = false;
  bool _isLooping = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = const Duration(minutes: 3, seconds: 45);

  String? get trackTitle => _trackTitle;
  String? get trackArtist => _trackArtist;
  String? get trackCoverUrl => _trackCoverUrl;
  bool get isPlaying => _isPlaying;
  bool get isLooping => _isLooping;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

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
    _userEmail = _prefs?.getString('userEmail') ?? "alex.fitza@gmail.com";
    _userName = _prefs?.getString('${_userEmail}_userName') ?? _prefs?.getString('userName') ?? "Alex Fit";
    _profileImagePath = _prefs?.getString('${_userEmail}_profileImagePath') ?? _prefs?.getString('profileImagePath');

    // Auto-restore cloud payload on startup if logged in
    final String activeId = _prefs?.getString('userId') ?? _userEmail;
    if (_isLoggedIn && activeId.isNotEmpty) {
      final cloudData = await CloudSyncService.restoreUserDataFromCloud(activeId);
      if (cloudData != null) {
        _restoreFromCloudPayload(cloudData);
      }
    }

    _isPhoneVerified = _prefs?.getBool('${_userEmail}_isPhoneVerified') ?? _prefs?.getBool('isPhoneVerified') ?? false;
    _verifiedPhoneNumber = _prefs?.getString('${_userEmail}_verifiedPhoneNumber') ?? _prefs?.getString('verifiedPhoneNumber');

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
    
    final themeIndex = _prefs?.getInt('themeMode') ?? 2; // Default system
    if (themeIndex >= 0 && themeIndex < AppThemeMode.values.length) {
      _currentTheme = AppThemeMode.values[themeIndex];
    }
    
    _geminiApiKey = _prefs?.getString('geminiApiKey');
    

    notifyListeners();
  }



  void setTheme(AppThemeMode mode) {
    _currentTheme = mode;
    _prefs?.setInt('themeMode', mode.index);
    notifyListeners();
  }

  // --- Auth Actions & Cloud Data Sync ---
  Future<void> loginWithGoogle(String mockName, String mockEmail) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      if (account != null) {
        _isLoggedIn = true;
        _userEmail = account.email;
        
        if (account.displayName != null && account.displayName!.trim().isNotEmpty) {
          _userName = account.displayName!.trim();
        } else {
          _userName = mockName;
        }

        if (account.photoUrl != null && account.photoUrl!.isNotEmpty) {
          _profileImagePath = account.photoUrl;
          await _prefs?.setString('${_userEmail}_profileImagePath', account.photoUrl!);
          await _prefs?.setString('profileImagePath', account.photoUrl!);
        }

        await _prefs?.setBool('isLoggedIn', true);
        await _prefs?.setString('userName', _userName);
        await _prefs?.setString('userEmail', _userEmail);
        await _prefs?.setString('userId', account.id);
        await _prefs?.setString('${_userEmail}_userName', _userName);

        // Auto-restore cloud data for Google Account
        final restoredCloudData = await CloudSyncService.restoreUserDataFromCloud(account.id);
        if (restoredCloudData != null) {
          _restoreFromCloudPayload(restoredCloudData);
        }

        await syncDataToCloud();
        notifyListeners();
        return;
      }
    } catch (error) {
      debugPrint("Google Sign In exception: $error. Falling back to test user session.");
    }

    _isLoggedIn = true;
    _userName = mockName;
    _userEmail = mockEmail;
    await _prefs?.setBool('isLoggedIn', true);
    await _prefs?.setString('userName', _userName);
    await _prefs?.setString('userEmail', _userEmail);

    final restoredCloudData = await CloudSyncService.restoreUserDataFromCloud(_userEmail);
    if (restoredCloudData != null) {
      _restoreFromCloudPayload(restoredCloudData);
    }

    await syncDataToCloud();
    notifyListeners();
  }

  Future<void> syncDataToCloud() async {
    final String activeId = _prefs?.getString('userId') ?? _userEmail;
    if (activeId.isEmpty) return;

    final payload = {
      'userId': activeId,
      'userName': _userName,
      'userEmail': _userEmail,
      'profileImagePath': _profileImagePath,
      'gender': _gender,
      'age': _age,
      'height': _height,
      'weight': _weight,
      'fitnessGoal': _fitnessGoal,
      'activityLevel': _activityLevel,
      'heightUnit': _heightUnit,
      'weightUnit': _weightUnit,
      'stepGoal': _stepGoal,
      'calorieGoal': _calorieGoal,
      'waterGoal': _waterGoal,
      'todaySteps': _todaySteps,
      'todayWater': _todayWater,
      'userXp': _userXp,
      'userLevel': userLevel,
      'currentStreak': _currentStreak,
      'isPhoneVerified': _isPhoneVerified,
      'verifiedPhoneNumber': _verifiedPhoneNumber,
      'currentTheme': _currentTheme == AppThemeMode.light ? 'light' : 'dark',
      'weightLogs': _weightLogs.map((e) => e.toJson()).toList(),
    };

    await CloudSyncService.saveUserDataToCloud(activeId, payload);
  }

  void _restoreFromCloudPayload(Map<String, dynamic> data) {
    if (data['userName'] != null) _userName = data['userName'];
    if (data['userEmail'] != null) _userEmail = data['userEmail'];
    if (data['profileImagePath'] != null) _profileImagePath = data['profileImagePath'];
    if (data['gender'] != null) _gender = data['gender'];
    if (data['age'] != null) _age = data['age'];
    if (data['height'] != null) _height = (data['height'] as num).toDouble();
    if (data['weight'] != null) _weight = (data['weight'] as num).toDouble();
    if (data['fitnessGoal'] != null) _fitnessGoal = data['fitnessGoal'];
    if (data['activityLevel'] != null) _activityLevel = data['activityLevel'];
    if (data['heightUnit'] != null) _heightUnit = data['heightUnit'];
    if (data['weightUnit'] != null) _weightUnit = data['weightUnit'];
    if (data['stepGoal'] != null) _stepGoal = data['stepGoal'];
    if (data['calorieGoal'] != null) _calorieGoal = data['calorieGoal'];
    if (data['waterGoal'] != null) _waterGoal = data['waterGoal'];
    if (data['todaySteps'] != null) _todaySteps = data['todaySteps'];
    if (data['todayWater'] != null) _todayWater = data['todayWater'];
    if (data['userXp'] != null) _userXp = data['userXp'];
    if (data['currentStreak'] != null) _currentStreak = data['currentStreak'];
    if (data['isPhoneVerified'] != null) _isPhoneVerified = data['isPhoneVerified'];
    if (data['verifiedPhoneNumber'] != null) _verifiedPhoneNumber = data['verifiedPhoneNumber'];
    if (data['currentTheme'] != null) {
      _currentTheme = data['currentTheme'] == 'light' ? AppThemeMode.light : AppThemeMode.dark;
    }

    if (data['weightLogs'] != null) {
      final List rawLogs = data['weightLogs'];
      _weightLogs = rawLogs.map((e) => WeightLog.fromJson(Map<String, dynamic>.from(e))).toList();
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await _prefs?.setBool('isLoggedIn', false);
    notifyListeners();
  }


  // --- Phone OTP Verification & Database Methods ---
  Future<String> sendPhoneOtp(String phoneNumber) async {
    _verifiedPhoneNumber = phoneNumber;
    final random = Random();
    _generatedOtp = (100000 + random.nextInt(900000)).toString();
    debugPrint("SMS OTP generated for $phoneNumber: $_generatedOtp");
    notifyListeners();
    return _generatedOtp!;
  }

  Future<bool> verifyPhoneOtp(String enteredCode) async {
    if (_generatedOtp != null && enteredCode.trim() == _generatedOtp!.trim()) {
      _isPhoneVerified = true;
      await _prefs?.setBool('${_userEmail}_isPhoneVerified', true);
      await _prefs?.setBool('isPhoneVerified', true);
      if (_verifiedPhoneNumber != null) {
        await _prefs?.setString('${_userEmail}_verifiedPhoneNumber', _verifiedPhoneNumber!);
        await _prefs?.setString('verifiedPhoneNumber', _verifiedPhoneNumber!);
      }
      notifyListeners();
      return true;
    }
    return false;
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
    required double weight,
    required double height,
    String? gender,
    String? activityLevel,
    String? heightUnit,
    String? weightUnit,
    String? fitnessGoal,
    String? fitnessLevel,
    String? workoutLocation,
    int? workoutDays,
    int? workoutDuration,
    int? stepGoal,
  }) async {
    _userName = name;
    _age = age;
    _height = height;
    _weight = weight;
    if (gender != null) _gender = gender;
    if (activityLevel != null) _activityLevel = activityLevel;
    if (heightUnit != null) _heightUnit = heightUnit;
    if (weightUnit != null) _weightUnit = weightUnit;
    if (fitnessGoal != null) _fitnessGoal = fitnessGoal;

    if (fitnessLevel != null) _fitnessLevel = fitnessLevel;
    if (workoutLocation != null) _workoutLocation = workoutLocation;
    if (workoutDays != null) _workoutDays = workoutDays;
    if (workoutDuration != null) _workoutDuration = workoutDuration;

    // Smart Auto-Calculations
    _calorieGoal = _calculateBmrCalories();
    _waterGoal = (_weight * 0.033 * 4).round().clamp(6, 16);
    
    if (stepGoal != null) {
      _stepGoal = stepGoal;
    } else if (activityLevel != null) {
      switch (_activityLevel) {
        case 'Sedentary':
          _stepGoal = 6000;
          break;
        case 'Lightly Active':
          _stepGoal = 8000;
          break;
        case 'Moderately Active':
          _stepGoal = 10000;
          break;
        case 'Very Active':
          _stepGoal = 12000;
          break;
        case 'Athlete':
          _stepGoal = 15000;
          break;
        default:
          _stepGoal = 8000;
      }
    }

    await _prefs?.setString('${_userEmail}_userName', name);
    await _prefs?.setInt('${_userEmail}_age', age);
    await _prefs?.setDouble('${_userEmail}_height', height);
    await _prefs?.setDouble('${_userEmail}_weight', weight);
    await _prefs?.setString('${_userEmail}_gender', _gender);
    await _prefs?.setString('${_userEmail}_activityLevel', _activityLevel);
    await _prefs?.setString('${_userEmail}_heightUnit', _heightUnit);
    await _prefs?.setString('${_userEmail}_weightUnit', _weightUnit);
    await _prefs?.setString('${_userEmail}_fitnessGoal', _fitnessGoal);
    await _prefs?.setString('${_userEmail}_fitnessLevel', _fitnessLevel);
    await _prefs?.setString('${_userEmail}_workoutLocation', _workoutLocation);
    await _prefs?.setInt('${_userEmail}_workoutDays', _workoutDays);
    await _prefs?.setInt('${_userEmail}_workoutDuration', _workoutDuration);
    await _prefs?.setInt('${_userEmail}_calorieGoal', _calorieGoal);
    await _prefs?.setInt('${_userEmail}_waterGoal', _waterGoal);
    await _prefs?.setInt('${_userEmail}_stepGoal', _stepGoal);

    await syncDataToCloud();
    notifyListeners();
  }

  int _calculateBmrCalories() {
    double bmr = (10 * _weight) + (6.25 * _height) - (5 * _age) + (_gender == "Female" ? -161 : 5);
    double mult = 1.2;
    switch (_activityLevel) {
      case 'Lightly Active':
        mult = 1.375;
        break;
      case 'Moderately Active':
        mult = 1.55;
        break;
      case 'Very Active':
        mult = 1.725;
        break;
      case 'Athlete':
        mult = 1.9;
        break;
    }
    double maintenance = bmr * mult;

    if (_fitnessGoal.contains("Lose")) return (maintenance - 500).round();
    if (_fitnessGoal.contains("Gain") || _fitnessGoal.contains("Muscle")) return (maintenance + 400).round();
    return maintenance.round();
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
    int lastKnown = _prefs?.getInt('${_userEmail}_lastKnownHardwareSteps') ?? -1;
    
    if (lastKnown != -1) {
      if (event.steps >= lastKnown) {
        int newSteps = event.steps - lastKnown;
        if (newSteps > 0) {
          _todaySteps += newSteps;
          _userXp += newSteps;
        }
      } else {
        // Device rebooted, pedometer reset
        int newSteps = event.steps;
        _todaySteps += newSteps;
        _userXp += newSteps;
      }
    }
    
    _prefs?.setInt('${_userEmail}_lastKnownHardwareSteps', event.steps);
    _prefs?.setInt('todaySteps', _todaySteps);
    _prefs?.setInt('${_userEmail}_todaySteps', _todaySteps);
    _prefs?.setInt('${_userEmail}_userXp', _userXp);
    
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
    _updateStepNotification();
    notifyListeners();
  }

  void togglePushNotifications(bool value) => setPushNotifications(value);

  void setStepGoal(int value) {
    _stepGoal = value;
    _prefs?.setInt('${_userEmail}_stepGoal', value);
    _updateStepNotification();
    notifyListeners();
  }

  void setCalorieGoal(int value) {
    _calorieGoal = value;
    _prefs?.setInt('${_userEmail}_calorieGoal', value);
    notifyListeners();
  }

  void setWeightUnit(String unit) {
    _weightUnit = unit;
    _prefs?.setString('${_userEmail}_weightUnit', unit);
    notifyListeners();
  }

  void setHeightUnit(String unit) {
    _heightUnit = unit;
    _prefs?.setString('${_userEmail}_heightUnit', unit);
    notifyListeners();
  }

  void syncToCloud() {
    syncDataToCloud();
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

  void resetLiveActivity() {
    _isTrackingActivity = false;
    _activityDistance = 0.0;
    _activitySeconds = 0;
    notifyListeners();
  }

  // --- Music Controls ---
  void playPauseMusic() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void nextMusic() {
    _currentPosition = Duration.zero;
    _isPlaying = true;
    notifyListeners();
  }

  void prevMusic() {
    _currentPosition = Duration.zero;
    _isPlaying = true;
    notifyListeners();
  }

  void toggleLooping() {
    _isLooping = !_isLooping;
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

  // --- Feature 1: Streak & Streak Freeze ---
  bool useStreakFreeze() {
    if (_streakFreezes > 0) {
      _streakFreezes--;
      _prefs?.setInt('${_userEmail}_streakFreezes', _streakFreezes);
      notifyListeners();
      return true;
    }
    return false;
  }

  void buyStreakFreeze() {
    if (_coins >= 150) {
      _coins -= 150;
      _streakFreezes++;
      _prefs?.setInt('${_userEmail}_coins', _coins);
      _prefs?.setInt('${_userEmail}_streakFreezes', _streakFreezes);
      notifyListeners();
    }
  }

  // --- Feature 4 & 15: XP & Coins Economy ---
  void addXp(int amount, {String? source}) {
    int oldLevel = userLevel;
    _userXp += amount;
    _prefs?.setInt('${_userEmail}_userXp', _userXp);
    if (userLevel > oldLevel) {
      _petHealth = 100;
      _coins += 100; // Level up bonus
    }
    notifyListeners();
  }

  void addCoins(int amount) {
    _coins += amount;
    _prefs?.setInt('${_userEmail}_coins', _coins);
    notifyListeners();
  }

  bool buyShopItem(String itemId, int cost) {
    if (_coins >= cost && !_ownedShopItems.contains(itemId)) {
      _coins -= cost;
      _ownedShopItems.add(itemId);
      if (itemId.contains('streak_freeze')) {
        _streakFreezes++;
      }
      _prefs?.setInt('${_userEmail}_coins', _coins);
      notifyListeners();
      return true;
    }
    return false;
  }

  // --- Feature 14: Daily Mystery Box ---
  Map<String, dynamic> claimMysteryBox() {
    final rand = Random();
    int rewardType = rand.nextInt(3);
    Map<String, dynamic> result = {};

    if (rewardType == 0) {
      int coinsEarned = 100 + rand.nextInt(200);
      addCoins(coinsEarned);
      result = {'title': '$coinsEarned Coins!', 'icon': '💰', 'type': 'coins', 'amount': coinsEarned};
    } else if (rewardType == 1) {
      int xpEarned = 250 + rand.nextInt(300);
      addXp(xpEarned, source: "Mystery Box");
      result = {'title': '$xpEarned XP Bonus!', 'icon': '⚡', 'type': 'xp', 'amount': xpEarned};
    } else {
      _streakFreezes++;
      _prefs?.setInt('${_userEmail}_streakFreezes', _streakFreezes);
      notifyListeners();
      result = {'title': '1 Streak Freeze!', 'icon': '🛡️', 'type': 'freeze', 'amount': 1};
    }
    return result;
  }

  // --- Feature 13: Weekly Boss Battle ---
  void attackBoss(int damage) {
    _bossCurrentHp = max(0, _bossCurrentHp - damage);
    if (_bossCurrentHp == 0) {
      addCoins(500);
      addXp(1000, source: "Boss Victory");
      _bossCurrentHp = 1000; // Reset boss
      if (!_unlockedBadges.contains('boss_slayer')) {
        _unlockedBadges.add('boss_slayer');
      }
    }
    notifyListeners();
  }

  // --- Feature 12: Fitness Pet ---
  void interactWithPet() {
    _petMood = "Energetic";
    _petHealth = min(100, _petHealth + 10);
    notifyListeners();
  }

  void changePetOutfit(String outfit) {
    _petOutfit = outfit;
    notifyListeners();
  }

  // --- Feature 19: Recovery Score ---
  void updateRecovery(int score, double sleep, String soreness) {
    _recoveryScore = score;
    _sleepHours = sleep;
    _sorenessLevel = soreness;
    notifyListeners();
  }

  // --- Feature 21: Dynamic Weather ---
  void setWeatherCondition(String condition, int temp) {
    _weatherCondition = condition;
    _weatherTemp = temp;
    notifyListeners();
  }

  // --- Feature 7: Muscle Heatmap ---
  void updateMuscleGlow(List<String> muscles) {
    for (var m in muscles) {
      if (_muscleHeatmap.containsKey(m)) {
        _muscleHeatmap[m] = 1.0; // Max intensity
      }
    }
    notifyListeners();
  }

  // --- Feature 20: Full Workout Log with Gamification ---
  void logWorkoutCompleted({
    required String name,
    required int calories,
    required int xp,
    required List<String> muscles,
    required int durationMinutes,
  }) {
    addXp(xp, source: name);
    addCoins(calories ~/ 3);
    attackBoss(calories);
    updateMuscleGlow(muscles);
    _petHealth = min(100, _petHealth + 15);
    _petMood = "Happy";
    _storyProgress = min(1.0, _storyProgress + 0.15);
    _currentStreak++;
    _prefs?.setInt('${_userEmail}_currentStreak', _currentStreak);
    notifyListeners();
  }

  // --- Feature 2: Smart AI Coach Dynamic Messages ---
  String getAiCoachMessage() {
    if (_currentStreak >= 7) {
      return "🔥 You completed 92% of your workouts this week. Let's keep your $_currentStreak-day streak burning strong!";
    } else if (_recoveryScore < 60) {
      return "❤️ Your recovery score is $_recoveryScore%. Today is ideal for an active recovery or stretching session.";
    } else if (_weatherCondition.toLowerCase() == "rainy") {
      return "🌧️ Rainy weather outside! Perfect day for an intense indoor home HIIT workout.";
    } else {
      return "💪 Your shoulders and chest are improving fast. Ready for today's workout?";
    }
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    _activityTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
}
