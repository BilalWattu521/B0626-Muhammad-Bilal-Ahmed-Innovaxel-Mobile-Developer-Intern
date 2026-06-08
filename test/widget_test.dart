import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('Expense Tracker UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the title is displayed.
    expect(find.text('Expense Tracker'), findsOneWidget);

    // Verify that the initial empty state message is shown.
    expect(find.text('No expenses yet'), findsOneWidget);

    // Verify that the add expense FAB exists.
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Verify that light/dark theme switch is visible.
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    // Verify NavigationBar exists
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);

    // Tap on the 'Summary' tab
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    // Verify that the Summary screen empty state is shown
    expect(find.text('No data available'), findsOneWidget);
  });
}
