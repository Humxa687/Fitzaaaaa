import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/fitness_provider.dart';
import 'core/theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/food_ai/food_ai_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/music/music_player_widget.dart';

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
          theme: FitzaTheme.getTheme(provider.currentTheme),
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

    // If logged in, check onboarding status
    if (provider.isLoggedIn) {
      if (provider.hasCompletedOnboarding) {
        return const MainNavigationLayout();
      } else {
        return const OnboardingScreen();
      }
    } else {
      return const LoginScreen();
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

  final List<Widget> _screens = [
    const DashboardScreen(),
    const FoodAiScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Current selected screen
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Persistent Floating Music Player Widget at the bottom
          const Positioned(
            left: 0,
            right: 0,
            bottom: kBottomNavigationBarHeight,
            child: MusicPlayerWidget(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            activeIcon: Icon(Icons.dashboard),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: "AI Food",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: "Progress",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
