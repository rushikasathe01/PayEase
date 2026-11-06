
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // =========================
  // LOGIN
  // =========================

  Future<void> _login() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      // Call backend login
      final result = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // =========================
      // LOGIN SUCCESS
      // =========================

      if (result == 'success') {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.dashboard,
        );

        return;
      }

      // =========================
      // LOGIN FAILED
      // =========================

      await _showLoginError(result);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      await _showLoginError(
        'Unable to connect to the server. Please make sure the PayEase backend is running.',
      );
    }
  }

  // =========================
  // LOGIN ERROR DIALOG
  // =========================

  Future<void> _showLoginError(String message) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Login Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =========================
                    // LOGO
                    // =========================

                    Center(
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 38,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // =========================
                    // TITLE
                    // =========================

                    const Center(
                      child: Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Center(
                      child: Text(
                        'Login to continue managing your finances',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 15,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // =========================
                    // EMAIL
                    // =========================

                    AppTextField(
                      label: 'Email Address',
                      hint: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType:
                          TextInputType.emailAddress,
                      controller: _emailController,
                      validator: Validators.email,
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // PASSWORD
                    // =========================

                    AppTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      controller: _passwordController,
                      validator: Validators.password,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // =========================
                    // REMEMBER + FORGOT
                    // =========================

                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _rememberMe =
                                        value ?? false;
                                  });
                                },
                        ),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            color: Color(0xFF475569),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.forgotPassword,
                                  );
                                },
                          child: const Text(
                            'Forgot Password?',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // =========================
                    // LOGIN BUTTON
                    // =========================

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =========================
                    // OR
                    // =========================

                    Row(
                      children: [
                        const Expanded(
                          child: Divider(),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // =========================
                    // CREATE ACCOUNT
                    // =========================

                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.signup,
                                );
                              },
                        child: const Text.rich(
                          TextSpan(
                            text:
                                "Don't have an account? ",
                            style: TextStyle(
                              color: Color(0xFF64748B),
                            ),
                            children: [
                              TextSpan(
                                text: 'Create Account',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

