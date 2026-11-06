
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text !=
        _confirmPasswordController.text) {
      _showErrorDialog(
        'Passwords do not match.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = await authProvider.resetPassword(
      email: _emailController.text.trim(),
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (!success) {
      _showErrorDialog(
        'The email address is not registered.\n\n'
        'Please enter the email address you used during signup.',
      );
      return;
    }

    await _showSuccessDialog();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text(
                'Reset Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
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

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Password Updated',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Your password has been updated successfully.\n\n'
            'You can now login using your new password.',
            style: TextStyle(
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
                'Go to Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
      ),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 42,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Center(
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Center(
                      child: Text(
                        'Enter your registered email and create a new password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    AppTextField(
                      label: 'Email Address',
                      hint: 'Enter your registered email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType:
                          TextInputType.emailAddress,
                      controller: _emailController,
                      validator: Validators.email,
                    ),

                    const SizedBox(height: 20),

                    AppTextField(
                      label: 'New Password',
                      hint: 'Enter your new password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureNewPassword,
                      controller: _newPasswordController,
                      validator: Validators.password,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword =
                                !_obscureNewPassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    AppTextField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your new password',
                      prefixIcon: Icons.lock_outline,
                      obscureText:
                          _obscureConfirmPassword,
                      controller:
                          _confirmPasswordController,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please confirm your password';
                        }

                        if (value !=
                            _newPasswordController.text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _resetPassword,
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
                                'Reset Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        },
                        child: const Text(
                          'Back to Login',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
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

