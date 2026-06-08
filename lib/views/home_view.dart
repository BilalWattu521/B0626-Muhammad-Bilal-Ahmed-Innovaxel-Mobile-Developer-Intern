import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../utils/helpers.dart';
import 'add_expense_view.dart';

class HomeView extends StatefulWidget {
  final ExpenseViewModel viewModel;

  const HomeView({super.key, required this.viewModel});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isFilterExpanded = false;
  String? _filterCategory;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  String _formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final expenseDate = DateTime(date.year, date.month, date.day);

    if (expenseDate == today) {
      return "Today";
    } else if (expenseDate == yesterday) {
      return "Yesterday";
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return "${months[date.month - 1]} ${date.day}, ${date.year}";
    }
  }



  String _getTopCategory(List<Expense> expenses) {
    final breakdown = <String, double>{};
    for (var expense in expenses) {
      breakdown[expense.category] =
          (breakdown[expense.category] ?? 0.0) + expense.amount;
    }
    if (breakdown.isEmpty) return "N/A";
    var topCat = breakdown.keys.first;
    var maxVal = breakdown.values.first;
    breakdown.forEach((cat, val) {
      if (val > maxVal) {
        maxVal = val;
        topCat = cat;
      }
    });
    return topCat;
  }

  void _showDeleteConfirmationDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text('Are you sure you want to delete "${expense.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.viewModel.deleteExpense(expense.id!);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickFilterDate(BuildContext context, {required bool isStartDate}) async {
    final initialDate = (isStartDate ? _filterStartDate : _filterEndDate) ?? DateTime.now();
    final firstDate = isStartDate ? DateTime(2020) : (_filterStartDate ?? DateTime(2020));
    final lastDate = isStartDate ? (_filterEndDate ?? DateTime(2100)) : DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _filterStartDate = picked;
        } else {
          _filterEndDate = picked;
        }
      });
    }
  }

  String _formatFilterDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  Widget _buildFilterPanel(BuildContext context) {
    final hasActiveFilters = (_filterCategory != null && _filterCategory != 'All') ||
        _filterStartDate != null ||
        _filterEndDate != null;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _filterCategory ?? 'All',
                    decoration: InputDecoration(
                      labelText: 'Filter Category',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ['All', ...widget.viewModel.categories].map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _filterCategory = value == 'All' ? null : value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickFilterDate(context, isStartDate: true),
                    icon: const Icon(Icons.date_range_rounded, size: 16),
                    label: Text(
                      _filterStartDate == null
                          ? 'Start Date'
                          : _formatFilterDate(_filterStartDate!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickFilterDate(context, isStartDate: false),
                    icon: const Icon(Icons.date_range_rounded, size: 16),
                    label: Text(
                      _filterEndDate == null
                          ? 'End Date'
                          : _formatFilterDate(_filterEndDate!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (hasActiveFilters) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _filterCategory = null;
                      _filterStartDate = null;
                      _filterEndDate = null;
                    });
                  },
                  icon: const Icon(Icons.clear_all_rounded, size: 16),
                  label: const Text('Clear Filters', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final filteredExpenses = widget.viewModel.expenses.where((expense) {
          if (_filterCategory != null &&
              _filterCategory != 'All' &&
              expense.category != _filterCategory) {
            return false;
          }
          if (_filterStartDate != null) {
            final expDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
            final startLimit = DateTime(_filterStartDate!.year, _filterStartDate!.month, _filterStartDate!.day);
            if (expDate.isBefore(startLimit)) {
              return false;
            }
          }
          if (_filterEndDate != null) {
            final expDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
            final endLimit = DateTime(_filterEndDate!.year, _filterEndDate!.month, _filterEndDate!.day);
            if (expDate.isAfter(endLimit)) {
              return false;
            }
          }
          return true;
        }).toList();

        final double totalExpenses = filteredExpenses.fold(0.0, (sum, item) => sum + item.amount);
        final String topCategory = _getTopCategory(filteredExpenses);
        final hasActiveFilters = (_filterCategory != null && _filterCategory != 'All') ||
            _filterStartDate != null ||
            _filterEndDate != null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            const Color(0xFF4F46E5),
                            const Color(0xFF312E81),
                          ]
                        : [
                            const Color(0xFF6366F1),
                            const Color(0xFF4338CA),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SPENDING',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs. ${ExpenseHelper.formatAmount(totalExpenses)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TRANSACTIONS',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${filteredExpenses.length} items',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TOP CATEGORY',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topCategory,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Expenses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      if (hasActiveFilters)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          _isFilterExpanded
                              ? Icons.filter_alt_rounded
                              : Icons.filter_alt_outlined,
                          color: _isFilterExpanded
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            _isFilterExpanded = !_isFilterExpanded;
                          });
                        },
                        tooltip: 'Filter Options',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              AnimatedCrossFade(
                firstChild: _buildFilterPanel(context),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _isFilterExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
              ),

              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              hasActiveFilters
                                  ? 'No matching expenses found'
                                  : 'No expenses yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hasActiveFilters
                                  ? 'Try adjusting or clearing your filters'
                                  : 'Tap the + button to add one',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final Expense expense = filteredExpenses[index];

                          bool showHeader = false;
                          if (index == 0) {
                            showHeader = true;
                          } else {
                            final prevExpense = filteredExpenses[index - 1];
                            final curDate = DateTime(expense.date.year,
                                expense.date.month, expense.date.day);
                            final prevDate = DateTime(prevExpense.date.year,
                                prevExpense.date.month, prevExpense.date.day);
                            if (curDate != prevDate) {
                              showHeader = true;
                            }
                          }

                          final itemColor = ExpenseHelper.getCategoryColor(expense.category);
                          final itemIcon = ExpenseHelper.getCategoryIcon(expense.category);

                          final expenseCard = Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: itemColor,
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: itemColor.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      itemIcon,
                                      color: itemColor,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    expense.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            expense.category,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (expense.notes != null &&
                                          expense.notes!.trim().isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          expense.notes!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '-Rs. ${ExpenseHelper.formatAmount(expense.amount)}',
                                        style: TextStyle(
                                          color: itemColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined,
                                            size: 18),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) =>
                                                AddExpenseView(
                                              viewModel: widget.viewModel,
                                              expenseToEdit: expense,
                                            ),
                                          );
                                        },
                                        tooltip: 'Edit Expense',
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18),
                                        color: Colors.red.shade400,
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(
                                              context, expense);
                                        },
                                        tooltip: 'Delete Expense',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );

                          if (showHeader) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 8.0, left: 4.0),
                                  child: Text(
                                    _formatHeaderDate(expense.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.8),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                expenseCard,
                              ],
                            );
                          }

                          return expenseCard;
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
