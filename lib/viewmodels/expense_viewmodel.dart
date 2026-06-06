import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';

class ExpenseViewModel extends ChangeNotifier {
  List<Expense> _expenses = [];
  List<String> _categories = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;

  double get totalExpenses =>
      _expenses.fold(0.0, (sum, item) => sum + item.amount);

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadExpensesSilently(),
        _loadCategoriesSilently(),
      ]);
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadExpensesSilently() async {
    _expenses = await DatabaseHelper.instance.getAllExpenses();
  }

  Future<void> _loadCategoriesSilently() async {
    _categories = await DatabaseHelper.instance.getCategories();
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await DatabaseHelper.instance.insert(expense);
      await _loadExpensesSilently();
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding expense: $e");
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await DatabaseHelper.instance.delete(id);
      await _loadExpensesSilently();
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting expense: $e");
    }
  }

  Future<bool> addCategory(String categoryName) async {
    try {
      final success = await DatabaseHelper.instance.insertCategory(categoryName);
      if (success) {
        await _loadCategoriesSilently();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error adding category: $e");
      return false;
    }
  }
}
