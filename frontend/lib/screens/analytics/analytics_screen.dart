import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Reports')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),

                const SizedBox(height: 20),

                _buildSummaryCards(provider),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  'Expense by Category',
                  'See where your money is going',
                ),

                const SizedBox(height: 14),

                _buildCategoryChart(provider),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  'Monthly Income vs Expense',
                  'Compare your monthly cash flow',
                ),

                const SizedBox(height: 14),

                _buildMonthlyChart(provider),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  'Spending Trend',
                  'Track your expenses over time',
                ),

                const SizedBox(height: 14),

                _buildSpendingTrend(provider),

                const SizedBox(height: 28),

                _buildSectionTitle(
                  'Financial Insights',
                  'Simple insights from your transactions',
                ),

                const SizedBox(height: 14),

                _buildInsights(provider),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Understand your spending, savings and income.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SUMMARY CARDS
  // --------------------------------------------------

  Widget _buildSummaryCards(TransactionProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'Income',
                value: provider.totalIncome,
                icon: Icons.arrow_downward_rounded,
                iconColor: const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'Expenses',
                value: provider.totalExpense,
                icon: Icons.arrow_upward_rounded,
                iconColor: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'Savings',
                value: provider.savings,
                icon: Icons.savings_outlined,
                iconColor: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _percentageCard(provider.savingsRate)),
          ],
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required double value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _percentageCard(double rate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.percent_rounded, color: Color(0xFF7C3AED)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Savings Rate',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            '${rate.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SECTION TITLE
  // --------------------------------------------------

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // CATEGORY CHART
  // --------------------------------------------------

  Widget _buildCategoryChart(TransactionProvider provider) {
    final data = provider.categoryExpenses;

    if (data.isEmpty) {
      return _emptyChart('No expense data available');
    }

    final total = data.values.fold<double>(0, (sum, value) => sum + value);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _chartDecoration(),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 55,
                sections: data.entries.map((entry) {
                  final percentage = (entry.value / total) * 100;

                  return PieChartSectionData(
                    value: entry.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 75,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ...data.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '₹${entry.value.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // MONTHLY BAR CHART
  // --------------------------------------------------

  Widget _buildMonthlyChart(TransactionProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
      decoration: _chartDecoration(),
      child: SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            maxY: _getMaxMonthlyValue(provider),
            barTouchData: BarTouchData(enabled: true),
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 45),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final month = value.toInt();

                    if (month < 1 || month > 12) {
                      return const SizedBox();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _monthName(month),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(12, (index) {
              final month = index + 1;

              final income = provider.monthlyIncome[month] ?? 0;

              final expense = provider.monthlyExpenses[month] ?? 0;

              return BarChartGroupData(
                x: month,
                barsSpace: 3,
                barRods: [
                  BarChartRodData(
                    toY: income,
                    width: 7,
                    color: const Color(0xFF059669),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  BarChartRodData(
                    toY: expense,
                    width: 7,
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  double _getMaxMonthlyValue(TransactionProvider provider) {
    double maxValue = 0;

    for (int month = 1; month <= 12; month++) {
      final income = provider.monthlyIncome[month] ?? 0;

      final expense = provider.monthlyExpenses[month] ?? 0;

      if (income > maxValue) {
        maxValue = income;
      }

      if (expense > maxValue) {
        maxValue = expense;
      }
    }

    if (maxValue == 0) {
      return 1000;
    }

    return maxValue * 1.2;
  }

  // --------------------------------------------------
  // SPENDING TREND
  // --------------------------------------------------

  Widget _buildSpendingTrend(TransactionProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 20),
      decoration: _chartDecoration(),
      child: SizedBox(
        height: 260,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: false),
            minX: 1,
            maxX: 12,
            minY: 0,
            maxY: _getMaxExpense(provider),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 45),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final month = value.toInt();

                    if (month < 1 || month > 12) {
                      return const SizedBox();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _monthName(month),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(12, (index) {
                  final month = index + 1;

                  final expense = provider.monthlyExpenses[month] ?? 0;

                  return FlSpot(month.toDouble(), expense);
                }),
                isCurved: true,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getMaxExpense(TransactionProvider provider) {
    double maxValue = 0;

    for (final value in provider.monthlyExpenses.values) {
      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue == 0) {
      return 1000;
    }

    return maxValue * 1.2;
  }

  // --------------------------------------------------
  // INSIGHTS
  // --------------------------------------------------

  Widget _buildInsights(TransactionProvider provider) {
    final categories = provider.categoryExpenses;

    String highestCategory = 'No expenses';

    double highestAmount = 0;

    for (final entry in categories.entries) {
      if (entry.value > highestAmount) {
        highestAmount = entry.value;
        highestCategory = entry.key;
      }
    }

    final savingsRate = provider.savingsRate;

    return Column(
      children: [
        _insightCard(
          icon: Icons.savings_outlined,
          title: 'Savings',
          message: savingsRate >= 50
              ? 'Excellent! You are saving more than half of your income.'
              : savingsRate >= 20
              ? 'Good job! Your savings are on a healthy track.'
              : 'Try to increase your savings by reducing unnecessary expenses.',
        ),
        const SizedBox(height: 10),
        _insightCard(
          icon: Icons.shopping_bag_outlined,
          title: 'Top Expense',
          message: highestAmount > 0
              ? '$highestCategory is your highest expense category at ₹${highestAmount.toStringAsFixed(0)}.'
              : 'Add some expenses to see your highest spending category.',
        ),
        const SizedBox(height: 10),
        _insightCard(
          icon: Icons.receipt_long_outlined,
          title: 'Transactions',
          message:
              'You currently have ${provider.transactionCount} transactions recorded in PayEase.',
        ),
      ],
    );
  }

  Widget _insightCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY CHART
  // --------------------------------------------------

  Widget _emptyChart(String message) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: _chartDecoration(),
      child: Center(
        child: Text(message, style: const TextStyle(color: Color(0xFF64748B))),
      ),
    );
  }

  BoxDecoration _chartDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
