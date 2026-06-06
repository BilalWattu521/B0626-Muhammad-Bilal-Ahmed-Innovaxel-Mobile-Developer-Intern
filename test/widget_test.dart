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
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });
}
