
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../services/report_export_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ============================================================
  // EXPORT REPORT
  // ============================================================

  Future<void> _exportReports(BuildContext context) async {
    final transactionProvider =
        context.read<TransactionProvider>();

    final accountProvider =
        context.read<AccountProvider>();

    // ----------------------------------------------------------
    // CHECK DATA
    // ----------------------------------------------------------

    if (accountProvider.accounts.isEmpty &&
        transactionProvider.transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No financial data available to export.',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // EXPORT CURRENT USER DATA
    // ----------------------------------------------------------

    try {
      ReportExportService.exportReport(
        accounts: accountProvider.accounts,
        transactions: transactionProvider.transactions,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Report exported successfully.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to export report: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, AuthProvider>(
      builder: (
        context,
        settings,
        auth,
        child,
      ) {
        // --------------------------------------------------------
        // CURRENT LOGGED-IN USER
        // --------------------------------------------------------

        final String currentName =
            auth.name?.isNotEmpty == true
                ? auth.name!
                : 'User';

        final String currentEmail =
            auth.email?.isNotEmpty == true
                ? auth.email!
                : 'No email';

        // --------------------------------------------------------
        // USER INITIAL
        // --------------------------------------------------------

        final String initial =
            currentName.isNotEmpty
                ? currentName[0].toUpperCase()
                : 'U';

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                // ==================================================
                // PROFILE HEADER
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(20),
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                  ),
                  child: Row(
                    children: [

                      // ------------------------------------------------
                      // AVATAR
                      // ------------------------------------------------

                      CircleAvatar(
                        radius: 35,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // ------------------------------------------------
                      // USER INFORMATION
                      // ------------------------------------------------

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              currentName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              currentEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // ACCOUNT SECTION
                // ==================================================

                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: Column(
                    children: [

                      // ------------------------------------------------
                      // EDIT PROFILE
                      // ------------------------------------------------

                      ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                        ),
                        title: const Text(
                          'Edit Profile',
                        ),
                        subtitle: const Text(
                          'Update your profile information',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () {
                          // Existing profile functionality
                          // can be connected here.
                        },
                      ),

                      const Divider(
                        height: 1,
                      ),

                      // ------------------------------------------------
                      // CHANGE PASSWORD
                      // ------------------------------------------------

                      ListTile(
                        leading: const Icon(
                          Icons.lock_outline,
                        ),
                        title: const Text(
                          'Change Password',
                        ),
                        subtitle: const Text(
                          'Update your account password',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () {
                          // Password functionality
                          // can be connected here.
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // REPORTS SECTION
                // ==================================================

                const Text(
                  'Reports',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.file_download_outlined,
                    ),
                    title: const Text(
                      'Export Reports',
                    ),
                    subtitle: const Text(
                      'Download your financial report',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),

                    // ------------------------------------------------
                    // ACTUAL EXPORT FUNCTION
                    // ------------------------------------------------

                    onTap: () {
                      _exportReports(context);
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // APP SECTION
                // ==================================================

                const Text(
                  'App',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Card(
                  child: Column(
                    children: [

                      // ------------------------------------------------
                      // NOTIFICATIONS
                      // ------------------------------------------------

                      ListTile(
                        leading: const Icon(
                          Icons.notifications_outlined,
                        ),
                        title: const Text(
                          'Notifications',
                        ),
                        subtitle: const Text(
                          'Manage notification settings',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () {
                          // Notification settings
                        },
                      ),

                      const Divider(
                        height: 1,
                      ),

                      // ------------------------------------------------
                      // ABOUT
                      // ------------------------------------------------

                      ListTile(
                        leading: const Icon(
                          Icons.info_outline,
                        ),
                        title: const Text(
                          'About PayEase',
                        ),
                        subtitle: const Text(
                          'Version 1.0.0',
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                        ),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'PayEase',
                            applicationVersion: '1.0.0',
                            applicationLegalese:
                                'Payment Management System',
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // LOGOUT
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.logout,
                    ),
                    label: const Text(
                      'Logout',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LOGOUT CONFIRMATION
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
          ),

          content: const Text(
            'Are you sure you want to logout?',
          ),

          actions: [

            // ------------------------------------------------------
            // CANCEL
            // ------------------------------------------------------

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),

            // ------------------------------------------------------
            // LOGOUT
            // ------------------------------------------------------

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await _logout(context);
              },
              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );
  }
}

