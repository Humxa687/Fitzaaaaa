import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/fitness_provider.dart';
import 'core/theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/dashboard/body_building_dashboard_screen.dart';
import 'features/food_ai/food_ai_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/music/music_player_widget.dart';

import 'features/music/music_player_widget.dart';
import 'features/dashboard/daily_start_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => FitnessProvider(),
      child: const FitzaApp(),
    ),
  );
}

class FitzaApp extends StatelessWidget {
  const FitzaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FitnessProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'Fitza - AI Fitness',
          theme: FitzaTheme.lightTheme,
          darkTheme: FitzaTheme.darkTheme,
          themeMode: provider.currentTheme == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,

          home: const AuthenticationWrapper(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);

    if (provider.isLoggedIn) {
      if (provider.hasCompletedOnboarding) {
        return const MainNavigationLayout();
      } else {
        return const OnboardingScreen();
      }
    } else {
      return const AuthScreen();
    }
  }
}

class MainNavigationLayout extends StatefulWidget {
  const MainNavigationLayout({super.key});

  @override
  State<MainNavigationLayout> createState() => _MainNavigationLayoutState();
}

class _MainNavigationLayoutState extends State<MainNavigationLayout> {
  int _currentIndex = 0;
  bool _isNavVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FitnessProvider>(context, listen: false);
      if (provider.needsDailyStart) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const DailyStartScreen(),
          fullscreenDialog: true,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<FitnessProvider>(context);

    // Dynamic Dashboard based on goal
    Widget currentDashboard = const DashboardScreen();
    if (provider.fitnessGoal.toLowerCase().contains("muscle") || 
        provider.fitnessGoal.toLowerCase().contains("body")) {
      currentDashboard = const BodyBuildingDashboardScreen();
    }

    final List<Widget> screens = [
      currentDashboard,
      const FoodAiScreen(),
      const ProgressScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: screens,
                ),
              ),
              if (provider.trackTitle != null)
                const MusicPlayerWidget(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                height: _isNavVisible ? 70 : 0,
                child: Wrap(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, -2))
                        ]
                      ),
                      child: BottomNavigationBar(
                        currentIndex: _currentIndex,
                        onTap: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: theme.colorScheme.surface,
                        selectedItemColor: theme.colorScheme.primary,
                        unselectedItemColor: Colors.grey,
                        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        items: const [
                          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), activeIcon: Icon(Icons.dashboard), label: "Home"),
                          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), activeIcon: Icon(Icons.camera_alt), label: "AI Food"),
                          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: "Progress"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            right: 16,
            bottom: _isNavVisible 
                ? 85
                : (provider.trackTitle != null ? 75 : 16),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isNavVisible = !_isNavVisible;
                });
              },
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => RotationTransition(turns: child.key == const ValueKey('up') ? anim : Tween<double>(begin: 1, end: 0).animate(anim), child: child),
                child: _isNavVisible 
                    ? const Icon(Icons.keyboard_arrow_down, key: ValueKey('down'))
                    : const Icon(Icons.menu, key: ValueKey('up')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
