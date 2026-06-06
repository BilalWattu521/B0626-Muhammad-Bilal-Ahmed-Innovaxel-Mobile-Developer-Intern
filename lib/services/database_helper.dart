import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  bool get _useSqlite {
    if (kIsWeb) return false;
    try {
      if (io.Platform.environment.containsKey('FLUTTER_TEST')) return false;
    } catch (_) {
      // Accessing Platform on web would throw, but kIsWeb guards it.
      // This catch is just an extra precaution.
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  // In-memory data for platforms where SQLite is not supported (Web, Desktop, etc.)
  final List<Expense> _inMemoryExpenses = [];
  int _inMemoryIdCounter = 1;
  final List<String> _inMemoryCategories = [
    'Food',
    'Utilities',
    'Entertainment',
    'Transport',
    'Shopping',
    'Health',
  ];

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$filePath';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');

    // Seed default categories
    final defaultCategories = [
      'Food',
      'Utilities',
      'Entertainment',
      'Transport',
      'Shopping',
      'Health',
    ];
    for (final category in defaultCategories) {
      await db.insert('categories', {'name': category});
    }
  }

  // --- Expenses Methods ---

  Future<Expense> insert(Expense expense) async {
    if (_useSqlite) {
      final db = await instance.database;
      final id = await db.insert('expenses', expense.toMap());
      return expense.copyWith(id: id);
    } else {
      final newExpense = expense.copyWith(id: _inMemoryIdCounter++);
      _inMemoryExpenses.add(newExpense);
      return newExpense;
    }
  }

  Future<List<Expense>> getAllExpenses() async {
    if (_useSqlite) {
      final db = await instance.database;
      final result = await db.query('expenses', orderBy: 'date DESC');
      return result.map((json) => Expense.fromMap(json)).toList();
    } else {
      final list = List<Expense>.from(_inMemoryExpenses);
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }
  }

  Future<int> delete(int id) async {
    if (_useSqlite) {
      final db = await instance.database;
      return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    } else {
      final index = _inMemoryExpenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _inMemoryExpenses.removeAt(index);
        return 1;
      }
      return 0;
    }
  }

  Future<int> update(Expense expense) async {
    if (_useSqlite) {
      final db = await instance.database;
      return await db.update(
        'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    } else {
      final index = _inMemoryExpenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _inMemoryExpenses[index] = expense;
        return 1;
      }
      return 0;
    }
  }

  // --- Categories Methods ---

  Future<List<String>> getCategories() async {
    if (_useSqlite) {
      final db = await instance.database;
      final result = await db.query('categories', orderBy: 'name ASC');
      return result.map((row) => row['name'] as String).toList();
    } else {
      final list = List<String>.from(_inMemoryCategories);
      list.sort();
      return list;
    }
  }

  Future<bool> insertCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    if (_useSqlite) {
      try {
        final db = await instance.database;
        // Check if exists first to avoid exception crashing the UI
        final existing = await db.query(
          'categories',
          where: 'name = ?',
          whereArgs: [trimmed],
        );
        if (existing.isNotEmpty) return false;

        await db.insert('categories', {'name': trimmed});
        return true;
      } catch (e) {
        debugPrint("Error inserting category: $e");
        return false;
      }
    } else {
      // Check case insensitive duplicate
      final exists = _inMemoryCategories.any(
        (c) => c.toLowerCase() == trimmed.toLowerCase(),
      );
      if (!exists) {
        _inMemoryCategories.add(trimmed);
        return true;
      }
      return false;
    }
  }
}
