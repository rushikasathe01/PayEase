
import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';

import '../screens/dashboard/dashboard_screen.dart';

import '../screens/transactions/add_transaction_screen.dart';
import '../screens/transactions/transaction_history_screen.dart';

import '../screens/accounts/accounts_screen.dart';

import '../screens/analytics/analytics_screen.dart';

import '../screens/settings/settings_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  static const String dashboard = '/dashboard';

  static const String addTransaction = '/add-transaction';
  static const String transactions = '/transactions';

  static const String accounts = '/accounts';

  static const String analytics = '/analytics';

  static const String settings = '/settings';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),

    login: (context) => const LoginScreen(),

    signup: (context) => const SignupScreen(),

    forgotPassword: (context) => const ForgotPasswordScreen(),

    dashboard: (context) => const DashboardScreen(),
    profile: (context) => const ProfileScreen(),

    addTransaction: (context) =>
        const AddTransactionScreen(),

    transactions: (context) =>
        const TransactionHistoryScreen(),

    accounts: (context) => const AccountsScreen(),

    analytics: (context) => const AnalyticsScreen(),

    settings: (context) => const SettingsScreen(),
  };
}

