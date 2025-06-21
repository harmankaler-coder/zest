import 'package:flutter/material.dart';
import 'package:twelve_week/screens/home_screen.dart';

// Entry point
void main() {
  runApp(const TwelveWeekYearApp());
}

class TwelveWeekYearApp extends StatelessWidget {
  const TwelveWeekYearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZEST',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}