import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/database_helper.dart';
import 'package:expense_tracker/viewmodels/expense_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExpenseViewModel Tests', () {
    late ExpenseViewModel viewModel;

    setUp(() {
      DatabaseHelper.instance.resetInMemory();
      viewModel = ExpenseViewModel();
    });

    test('Initial states are correct', () {
      expect(viewModel.expenses, isEmpty);
      expect(viewModel.categories, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.totalExpenses, 0.0);
    });

    test('Loads default categories and empty expenses', () async {
      await viewModel.loadAllData();
      expect(viewModel.expenses, isEmpty);
      expect(viewModel.categories, isNotEmpty);
      expect(viewModel.categories, contains('Food'));
      expect(viewModel.categories, contains('Utilities'));
    });

    test('Add custom category works and persists', () async {
      await viewModel.loadAllData();
      final originalCount = viewModel.categories.length;

      final success = await viewModel.addCategory('Groceries');
      expect(success, isTrue);
      expect(viewModel.categories.length, originalCount + 1);
      expect(viewModel.categories, contains('Groceries'));

      // Re-adding same category should fail
      final fail = await viewModel.addCategory('Groceries');
      expect(fail, isFalse);
    });

    test('CRUD operations for expenses work correctly', () async {
      await viewModel.loadAllData();

      // Add expense 1
      final expense1 = Expense(
        title: 'Lunch',
        amount: 12.50,
        category: 'Food',
        date: DateTime(2026, 6, 1, 12, 0),
      );
      await viewModel.addExpense(expense1);

      expect(viewModel.expenses.length, 1);
      expect(viewModel.expenses.first.title, 'Lunch');
      expect(viewModel.totalExpenses, 12.50);

      // Add expense 2 (more recent date)
      final expense2 = Expense(
        title: 'Electricity Bill',
        amount: 80.00,
        category: 'Utilities',
        date: DateTime(2026, 6, 2, 10, 0),
      );
      await viewModel.addExpense(expense2);

      // Verifying sort order (most recent first)
      expect(viewModel.expenses.length, 2);
      expect(viewModel.expenses[0].title, 'Electricity Bill');
      expect(viewModel.expenses[1].title, 'Lunch');
      expect(viewModel.totalExpenses, 92.50);

      // Delete expense
      final idToDelete = viewModel.expenses[1].id;
      expect(idToDelete, isNotNull);
      await viewModel.deleteExpense(idToDelete!);

      expect(viewModel.expenses.length, 1);
      expect(viewModel.expenses.first.title, 'Electricity Bill');
      expect(viewModel.totalExpenses, 80.00);
    });

    test('Updating an expense works correctly', () async {
      await viewModel.loadAllData();

      final expense = Expense(
        title: 'Original Title',
        amount: 100.00,
        category: 'Food',
        date: DateTime(2026, 6, 3),
      );
      await viewModel.addExpense(expense);

      final added = viewModel.expenses.first;
      expect(added.title, 'Original Title');
      expect(viewModel.totalExpenses, 100.00);

      final updated = added.copyWith(
        title: 'Updated Title',
        amount: 250.50,
      );
      await viewModel.updateExpense(updated);

      expect(viewModel.expenses.length, 1);
      expect(viewModel.expenses.first.title, 'Updated Title');
      expect(viewModel.expenses.first.amount, 250.50);
      expect(viewModel.totalExpenses, 250.50);
    });
  });
}
