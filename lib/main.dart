import 'package:flutter/material.dart';
import 'services/theme_manager.dart';
import 'views/home_view.dart';

final ThemeManager themeManager = ThemeManager();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, _) {
        return MaterialApp(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          themeMode: themeManager.themeMode,
          // Premium Light Theme
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1), // Modern Violet/Indigo
              brightness: Brightness.light,
              background: const Color(0xFFF8FAFC), // Off-white/slate-50
              surface: Colors.white,
              onBackground: const Color(0xFF0F172A),
              onSurface: const Color(0xFF1E293B),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              iconTheme: IconThemeData(color: Color(0xFF0F172A)),
            ),
            cardTheme: const CardThemeData(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          // Premium Dark Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF818CF8), // Muted light indigo
              brightness: Brightness.dark,
              background: const Color(0xFF0B0F19), // Deep rich space black/navy
              surface: const Color(0xFF161E2E), // Slate dark surface
              onBackground: const Color(0xFFF1F5F9),
              onSurface: const Color(0xFFE2E8F0),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Color(0xFFF1F5F9),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
              iconTheme: IconThemeData(color: Color(0xFFF1F5F9)),
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF161E2E),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          home: const HomeView(),
        );
      },
    );
  }
}
