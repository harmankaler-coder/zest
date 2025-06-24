import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/enhanced_home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/storage_services.dart';

void main() {
  runApp(const TwelveWeekYearApp());
}

class TwelveWeekYearApp extends StatefulWidget {
  const TwelveWeekYearApp({super.key});

  @override
  State<TwelveWeekYearApp> createState() => TwelveWeekYearAppState();
}

class TwelveWeekYearAppState extends State<TwelveWeekYearApp> {
  ThemeMode themeMode = ThemeMode.system;
  bool showSplash = true;

  @override
  void initState() {
    super.initState();
    loadThemeMode();
    checkFirstLaunch();
  }

  Future<void> loadThemeMode() async {
    final settings = await StorageService.loadSettings();
    final themeMode = settings['theme_mode'] ?? 'system';
    setState(() {
      switch (themeMode) {
        case 'light':
          this.themeMode = ThemeMode.light;
          break;
        case 'dark':
          this.themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          this.themeMode = ThemeMode.system;
          break;
      }
    });
  }

  Future<void> checkFirstLaunch() async {
    final settings = await StorageService.loadSettings();
    final hasSeenSplash = settings['has_seen_splash'] ?? false;

    if (hasSeenSplash) {
      setState(() {
        showSplash = false;
      });
    }
  }

  Future<void> onGetStarted() async {
    // Mark that user has seen the splash screen
    final settings = await StorageService.loadSettings();
    settings['has_seen_splash'] = true;
    await StorageService.saveSettings(settings);

    setState(() {
      showSplash = false;
    });
  }

  void updateThemeMode(ThemeMode themeMode) {
    setState(() {
      this.themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '12 Week Year',
      themeMode: themeMode,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF667eea),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF667eea),
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C3E50),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF667eea),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: showSplash
          ? SplashScreen(onGetStarted: onGetStarted)
          : EnhancedHomeScreen(onThemeChanged: updateThemeMode),
    );
  }
}