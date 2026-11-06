import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'theme.dart';

import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';

class PayEaseApp extends StatelessWidget {
  const PayEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
         ChangeNotifierProvider(
      create: (_) => AuthProvider(),
    ),

      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PayEase',

            theme: AppTheme.lightTheme,

            darkTheme: AppTheme.darkTheme,

            themeMode: settingsProvider.darkModeEnabled
                ? ThemeMode.dark
                : ThemeMode.light,

            initialRoute: AppRoutes.splash,

            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
