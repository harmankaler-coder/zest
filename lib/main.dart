import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/enhanced_home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const TwelveWeekYearApp());
}

class TwelveWeekYearApp extends StatefulWidget {
  const TwelveWeekYearApp({super.key});

  @override
  State<TwelveWeekYearApp> createState() => _TwelveWeekYearAppState();
}

class _TwelveWeekYearAppState extends State<TwelveWeekYearApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _checkFirstLaunch();
  }

  Future<void> _loadThemeMode() async {
    final settings = await StorageService.loadSettings();
    final themeMode = settings['theme_mode'] ?? 'system';
    setState(() {
      switch (themeMode) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }
    });
  }

  Future<void> _checkFirstLaunch() async {
    final settings = await StorageService.loadSettings();
    final hasSeenSplash = settings['has_seen_splash'] ?? false;
    
    if (hasSeenSplash) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  Future<void> _onGetStarted() async {
    // Mark that user has seen the splash screen
    final settings = await StorageService.loadSettings();
    settings['has_seen_splash'] = true;
    await StorageService.saveSettings(settings);
    
    setState(() {
      _showSplash = false;
    });
  }

  void updateThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '12 Week Year',
      themeMode: _themeMode,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardTheme(
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
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardTheme(
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
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
        ),
      ),
      home: _showSplash 
          ? SplashScreen(onGetStarted: _onGetStarted)
          : EnhancedHomeScreen(onThemeChanged: updateThemeMode),
    );
  }
}