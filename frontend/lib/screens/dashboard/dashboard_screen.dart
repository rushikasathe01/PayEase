
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/routes.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;

  DateTime _currentDateTime = DateTime.now();

  String _userName = 'User';

  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();

    // Load logged-in user's name.
    _loadUserName();

    // Update the clock every second.
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (mounted) {
          setState(() {
            _currentDateTime = DateTime.now();
          });
        }
      },
    );

    // Load accounts and transactions after Dashboard is created.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // =========================================================
  // LOAD USER NAME
  // =========================================================

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedName = prefs.getString('payease_user_name');

      if (mounted &&
          savedName != null &&
          savedName.trim().isNotEmpty) {
        setState(() {
          _userName = savedName.trim();
        });
      }
    } catch (error) {
      debugPrint(
        'Dashboard username loading error: $error',
      );
    }
  }

  // =========================================================
  // LOAD DASHBOARD DATA FROM BACKEND
  // =========================================================

  Future<void> _loadDashboardData() async {
    if (_isLoadingData) {
      return;
    }

    _isLoadingData = true;

    try {
      final authProvider = context.read<AuthProvider>();

      final token = authProvider.token;

      if (token == null || token.isEmpty) {
        debugPrint(
          'Dashboard: No authentication token found.',
        );
        return;
      }

      debugPrint(
        'Dashboard: Loading accounts and transactions...',
      );

      // Load accounts from MongoDB.
      await context
          .read<AccountProvider>()
          .loadAccounts(token);

      // Load transactions from MongoDB.
      await context
          .read<TransactionProvider>()
          .loadTransactions(token);

      debugPrint(
        'Dashboard: Accounts and transactions loaded.',
      );

      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      debugPrint(
        'Dashboard data loading error: $error',
      );
    } finally {
      _isLoadingData = false;
    }
  }

  // =========================================================
  // GET GREETING
  // =========================================================

  String _getGreeting() {
    final hour = _currentDateTime.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    }

    if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    }

    if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    }

    return 'Good Night';
  }

  // =========================================================
  // GET GREETING ICON
  // =========================================================

  IconData _getGreetingIcon() {
    final hour = _currentDateTime.hour;

    if (hour >= 5 && hour < 12) {
      return Icons.wb_sunny_rounded;
    }

    if (hour >= 12 && hour < 17) {
      return Icons.wb_sunny_outlined;
    }

    if (hour >= 17 && hour < 21) {
      return Icons.wb_twilight_rounded;
    }

    return Icons.nightlight_round;
  }

  // =========================================================
  // GET CURRENT TIME
  // =========================================================

  String _getCurrentTime() {
    final hour = _currentDateTime.hour;

    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;

    final minute =
        _currentDateTime.minute.toString().padLeft(2, '0');

    final second =
        _currentDateTime.second.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'PM' : 'AM';

    return '${displayHour.toString().padLeft(2, '0')}:'
        '$minute:$second $period';
  }

  // =========================================================
  // GET CURRENT DATE
  // =========================================================

  String _getCurrentDate() {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final weekday =
        weekdays[_currentDateTime.weekday - 1];

    final month =
        months[_currentDateTime.month - 1];

    return '$weekday, '
        '${_currentDateTime.day} '
        '$month '
        '${_currentDateTime.year}';
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<TransactionProvider, AccountProvider>(
          builder: (
            context,
            transactionProvider,
            accountProvider,
            child,
          ) {
            final transactions =
                transactionProvider.transactions;

            return RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      30,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // =========================
                        // HEADER
                        // =========================

                        _buildHeader(context),

                        const SizedBox(height: 24),

                        // =========================
                        // BALANCE CARD
                        // =========================

                        BalanceCard(
                          balance:
                              accountProvider.totalAccountBalance,
                        ),

                        const SizedBox(height: 16),

                        // =========================
                        // INCOME + EXPENSE
                        // =========================

                        Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                title: 'Income',
                                amount:
                                    transactionProvider.totalIncome,
                                icon:
                                    Icons.arrow_downward_rounded,
                                iconBackground:
                                    const Color(0xFFECFDF5),
                                iconColor:
                                    const Color(0xFF059669),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: SummaryCard(
                                title: 'Expenses',
                                amount:
                                    transactionProvider.totalExpense,
                                icon:
                                    Icons.arrow_upward_rounded,
                                iconBackground:
                                    const Color(0xFFFEF2F2),
                                iconColor:
                                    const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // =========================
                        // QUICK ACTIONS TITLE
                        // =========================

                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // =========================
                        // QUICK ACTIONS
                        // =========================

                        _buildQuickActions(context),

                        const SizedBox(height: 15),

                        // =========================
                        // MY ACCOUNTS
                        // =========================

                        _buildAccountsButton(context),

                        const SizedBox(height: 30),

                        // =========================
                        // RECENT TRANSACTIONS
                        // =========================

                        Row(
                          children: [
                            const Text(
                              'Recent Transactions',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const Spacer(),

                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.transactions,
                                );
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // =========================
                        // TRANSACTION LIST
                        // =========================

                        if (_isLoadingData &&
                            transactions.isEmpty)
                          _buildLoadingState()
                        else if (transactions.isEmpty)
                          _buildEmptyState()
                        else
                          ...transactions
                              .take(5)
                              .map(
                                (transaction) => Padding(
                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  child: TransactionCard(
                                    transaction: transaction,
                                  ),
                                ),
                              ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================

      bottomNavigationBar:
          _buildBottomNavigationBar(context),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Avatar
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              _userName.isNotEmpty
                  ? _userName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Greeting + Name + Date + Time
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getGreetingIcon(),
                    size: 16,
                    color: const Color(0xFF64748B),
                  ),

                  const SizedBox(width: 5),

                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 3),

              // Logged-in user's name
              Text(
                _userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              // Date
              Text(
                _getCurrentDate(),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 3),

              // Live Time
              Text(
                _getCurrentTime(),
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Notification Button
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // QUICK ACTIONS
  // =========================================================

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        // Income
        Expanded(
          child: _quickAction(
            icon: Icons.add_rounded,
            title: 'Income',
            color: const Color(0xFF059669),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.addTransaction,
              );
            },
          ),
        ),

        const SizedBox(width: 10),

        // Expense
        Expanded(
          child: _quickAction(
            icon: Icons.remove_rounded,
            title: 'Expense',
            color: const Color(0xFFDC2626),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.addTransaction,
              );
            },
          ),
        ),

        const SizedBox(width: 10),

        // Transfer
        Expanded(
          child: _quickAction(
            icon: Icons.swap_horiz_rounded,
            title: 'Transfer',
            color: const Color(0xFF2563EB),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.addTransaction,
              );
            },
          ),
        ),
      ],
    );
  }

  // =========================================================
  // MY ACCOUNTS BUTTON
  // =========================================================

  Widget _buildAccountsButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.accounts,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: Color(0xFF2563EB),
            ),

            SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Accounts',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 3),

                  Text(
                    'Manage bank, cash, card and UPI accounts',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // QUICK ACTION BUTTON
  // =========================================================

  Widget _quickAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // LOADING STATE
  // =========================================================

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: const Column(
        children: [
          SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          ),

          SizedBox(height: 12),

          Text(
            'Loading transactions...',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY TRANSACTION STATE
  // =========================================================

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 45,
            color: Color(0xFF94A3B8),
          ),

          SizedBox(height: 12),

          Text(
            'No transactions yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Your recent transactions will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // BOTTOM NAVIGATION
  // =========================================================

  Widget _buildBottomNavigationBar(
    BuildContext context,
  ) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        // Home
        if (index == 0) {
          return;
        }

        // Transactions
        if (index == 1) {
          Navigator.pushNamed(
            context,
            AppRoutes.transactions,
          );
        }

        // Analytics
        if (index == 2) {
          Navigator.pushNamed(
            context,
            AppRoutes.analytics,
          );
        }

        // Profile
        if (index == 3) {
          Navigator.pushNamed(
            context,
            AppRoutes.settings,
          );
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),

        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon:
              Icon(Icons.receipt_long_rounded),
          label: 'Transactions',
        ),

        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon:
              Icon(Icons.analytics_rounded),
          label: 'Analytics',
        ),

        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon:
              Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
