import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _checkUser();
  }

  Future<void> _checkUser() async {
    // Give the splash screen some time to display.
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    // ------------------------------------------------------------
    // RESTORE BACKEND LOGIN SESSION
    // ------------------------------------------------------------
    //
    // This checks whether a JWT token was saved locally.
    // If a token exists, the backend verifies it using /api/auth/me.
    //
    final isLoggedIn =
        await authProvider.restoreSession();

    if (!mounted) return;

    if (isLoggedIn) {
      // ----------------------------------------------------------
      // TOKEN IS VALID
      // ----------------------------------------------------------
      //
      // User is already authenticated.
      // Go directly to Dashboard.
      //
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.dashboard,
      );
    } else {
      // ----------------------------------------------------------
      // NO VALID SESSION
      // ----------------------------------------------------------
      //
      // User needs to log in.
      //
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.login,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1D4ED8),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 55,
                  color: Color(0xFF2563EB),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                AppConstants.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 50),

              const SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}