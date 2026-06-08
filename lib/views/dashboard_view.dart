import 'package:flutter/material.dart';
import '../main.dart' show themeManager;
import '../viewmodels/expense_viewmodel.dart';
import 'home_view.dart';
import 'summary_view.dart';
import 'add_expense_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final ExpenseViewModel _viewModel;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = ExpenseViewModel();
    _viewModel.loadAllData();
  }

  void _openAddExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseView(viewModel: _viewModel),
    );
  }

  Widget _buildThemeTab(
      BuildContext context, ThemeMode mode, IconData icon) {
    final isSelected = themeManager.themeMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => themeManager.setThemeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E293B) : Colors.white)
              : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      HomeView(viewModel: _viewModel),
      SummaryView(viewModel: _viewModel),
    ];

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: const Text('Expense Tracker'),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildThemeTab(context, ThemeMode.light,
                        Icons.light_mode_rounded),
                    _buildThemeTab(
                        context, ThemeMode.dark, Icons.dark_mode_rounded),
                  ],
                ),
              ),
            ],
          ),
          body: _viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : IndexedStack(
                  index: _currentIndex,
                  children: screens,
                ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.receipt_long_rounded),
                label: 'Expenses',
              ),
              NavigationDestination(
                icon: Icon(Icons.pie_chart_rounded),
                label: 'Summary',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openAddExpenseModal,
            tooltip: 'Add Expense',
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        );
      },
    );
  }
}
