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
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
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
    final settings = await StorageService.loadSettings();
    settings['has_seen_splash'] = true;
    await StorageService.saveSettings(settings);
    
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '12 Week Year',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF000000), // Pure black for AMOLED
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          headlineLarge: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          titleSmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 1.5,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 1.5,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
            height: 1.4,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF111111),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actionsIconTheme: const IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: const Color(0xFF6C63FF).withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6C63FF),
            side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6C63FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: const Color(0xFF111111),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF111111),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF333333)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
          ),
          labelStyle: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.inter(
            color: Colors.white38,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF111111),
          selectedItemColor: Color(0xFF6C63FF),
          unselectedItemColor: Colors.white38,
          type: BottomNavigationBarType.fixed,
          elevation: 16,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF9C88FF),
          tertiary: Color(0xFF4ECDC4),
          surface: Color(0xFF111111),
          background: Color(0xFF000000),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onTertiary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
          error: Color(0xFFFF6B6B),
          onError: Colors.white,
          outline: Color(0xFF333333),
          surfaceVariant: Color(0xFF1A1A1A),
          onSurfaceVariant: Colors.white70,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: const Color(0xFF111111),
          elevation: 24,
          shadowColor: Colors.black.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          contentTextStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 1.5,
          ),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: const Color(0xFF111111),
          elevation: 16,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: MaterialStatePropertyAll(Color(0xFF111111)),
            elevation: MaterialStatePropertyAll(16),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF111111),
          contentTextStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 8,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF1A1A1A),
          selectedColor: const Color(0xFF6C63FF).withOpacity(0.2),
          disabledColor: const Color(0xFF333333),
          labelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          secondaryLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          pressElevation: 8,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF6C63FF);
            }
            return Colors.white38;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF6C63FF).withOpacity(0.3);
            }
            return Colors.white12;
          }),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF6C63FF),
          inactiveTrackColor: const Color(0xFF6C63FF).withOpacity(0.3),
          thumbColor: const Color(0xFF6C63FF),
          overlayColor: const Color(0xFF6C63FF).withOpacity(0.2),
          valueIndicatorColor: const Color(0xFF6C63FF),
          valueIndicatorTextStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF6C63FF),
          linearTrackColor: Color(0xFF333333),
          circularTrackColor: Color(0xFF333333),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: const Color(0xFF6C63FF),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        listTileTheme: ListTileThemeData(
          tileColor: const Color(0xFF111111),
          selectedTileColor: const Color(0xFF6C63FF).withOpacity(0.1),
          iconColor: Colors.white70,
          textColor: Colors.white,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          subtitleTextStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF333333),
          thickness: 1,
          space: 1,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF6C63FF);
            }
            return Colors.transparent;
          }),
          checkColor: MaterialStateProperty.all(Colors.white),
          side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF6C63FF);
            }
            return Colors.white38;
          }),
        ),
      ),
      home: _showSplash 
          ? SplashScreen(onGetStarted: _onGetStarted)
          : const EnhancedHomeScreen(),
    );
  }
}