import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../utils/helpers.dart';

class SummaryView extends StatelessWidget {
  final ExpenseViewModel viewModel;

  const SummaryView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final expenses = viewModel.expenses;
    final total = viewModel.totalExpenses;

    if (expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 80,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 16),
              Text(
                'No data available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add some expenses under the Expenses tab to see category breakdown summaries.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Group expenses by category
    final breakdown = <String, double>{};
    for (final expense in expenses) {
      breakdown[expense.category] =
          (breakdown[expense.category] ?? 0.0) + expense.amount;
    }

    // Sort categories by amount descending
    final sortedCategories = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Prepare colors for chart segments corresponding to the categories in breakdown
    final colorList = sortedCategories
        .map((e) => ExpenseHelper.getCategoryColor(e.key))
        .toList();

    final dataMap = <String, double>{};
    for (final entry in sortedCategories) {
      dataMap[entry.key] = entry.value;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 16.0,
              ),
              child: Column(
                children: [
                  Text(
                    'Category Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PieChart(
                    dataMap: dataMap,
                    animationDuration: const Duration(milliseconds: 600),
                    chartRadius: MediaQuery.of(context).size.width / 2.5,
                    colorList: colorList,
                    initialAngleInDegree: 270,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 20,
                    centerWidget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TOTAL SPENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rs. ${ExpenseHelper.formatAmount(total)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    legendOptions: LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.right,
                      showLegends: true,
                      legendShape: BoxShape.circle,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: false,
                      showChartValues: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedCategories.length,
            itemBuilder: (context, index) {
              final entry = sortedCategories[index];
              final category = entry.key;
              final amount = entry.value;
              final percent = (amount / total) * 100;
              final catColor = ExpenseHelper.getCategoryColor(category);
              final catIcon = ExpenseHelper.getCategoryIcon(category);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(catIcon, color: catColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs. ${ExpenseHelper.formatAmount(amount)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${percent.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: amount / total,
                        backgroundColor: catColor.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(catColor),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
