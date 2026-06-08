import 'package:flutter/material.dart';

class ExpenseHelper {
  static String formatAmount(double amount) {
    if (amount == amount.toInt()) {
      return amount.toInt().toString();
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFF97316);
      case 'utilities':
        return const Color(0xFFEAB308);
      case 'entertainment':
        return const Color(0xFFA855F7);
      case 'transport':
        return const Color(0xFF3B82F6);
      case 'shopping':
        return const Color(0xFFEC4899);
      case 'health':
        return const Color(0xFFEF4444);
      default:
        final hash = category.hashCode;
        final colors = [
          Colors.teal,
          Colors.cyan,
          Colors.indigo,
          const Color(0xFF10B981),
          const Color(0xFFF43F5E),
          Colors.deepOrange,
        ];
        return colors[hash.abs() % colors.length];
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood_rounded;
      case 'utilities':
        return Icons.lightbulb_rounded;
      case 'entertainment':
        return Icons.movie_filter_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'health':
        return Icons.local_hospital_rounded;
      default:
        return Icons.label_rounded;
    }
  }
}
