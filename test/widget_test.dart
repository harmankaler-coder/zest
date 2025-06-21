// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:twelve_week/main.dart';

void main() {
  testWidgets('App launches and shows empty state', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TwelveWeekYearApp());

    // Verify that the app shows the empty state message
    expect(find.text('No goals yet.\nTap + to add your first goal!'), findsOneWidget);
    
    // Verify that the floating action button is present
    expect(find.byIcon(Icons.add), findsOneWidget);
    
    // Verify that the app bar title is present
    expect(find.text('ZEST'), findsOneWidget);
  });

  testWidgets('Can navigate to add goal screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TwelveWeekYearApp());

    // Tap the '+' icon to add a goal
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify that we navigated to the add goal screen
    expect(find.text('Add Goal'), findsOneWidget);
    expect(find.text('Goal Title'), findsOneWidget);
  });
}