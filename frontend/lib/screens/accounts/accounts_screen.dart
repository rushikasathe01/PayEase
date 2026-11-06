
import 'package:flutter/material.dart';
import 'package:payeaseproject/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/account_provider.dart';
import '../../widgets/account_card.dart';
import 'add_account_screen.dart';
import 'transfer_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  bool _hasLoadedAccounts = false;

  // ============================================================
  // LOAD ACCOUNTS FROM BACKEND
  // ============================================================

  Future<void> _loadAccounts() async {
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login again.'),
        ),
      );

      return;
    }

    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    await accountProvider.loadAccounts(token);
  }

  // ============================================================
  // INITIAL LOAD
  // ============================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasLoadedAccounts) {
      _hasLoadedAccounts = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadAccounts();
        }
      });
    }
  }

  // ============================================================
  // OPEN ADD ACCOUNT SCREEN
  // ============================================================

  Future<void> _openAddAccount() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAccountScreen(),
      ),
    );

    if (mounted) {
      await _refreshAccounts();
    }
  }

  // ============================================================
  // OPEN EDIT ACCOUNT SCREEN
  // ============================================================

  Future<void> _openEditAccount(account) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountScreen(
          account: account,
        ),
      ),
    );

    if (mounted) {
      await _refreshAccounts();
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> _deleteAccount(
    BuildContext context,
    String accountId,
    String accountName,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Account?',
          ),
          content: Text(
            'Are you sure you want to delete "$accountName"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login again.',
          ),
        ),
      );

      return;
    }

    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    final success = await accountProvider.deleteAccount(
      token: token,
      id: accountId,
    );

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account deleted successfully',
          ),
        ),
      );

      await _refreshAccounts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accountProvider.errorMessage ??
                'Unable to delete account',
          ),
        ),
      );
    }
  }

  // ============================================================
  // REFRESH ACCOUNTS
  // ============================================================

  Future<void> _refreshAccounts() async {
    await _loadAccounts();
  }

  // ============================================================
  // TRANSFER MONEY
  // ============================================================

  void _openTransferScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransferScreen(),
      ),
    ).then((_) {
      if (mounted) {
        _refreshAccounts();
      }
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'My Accounts',
        ),
        centerTitle: true,

        actions: [
          // ----------------------------------------------------
          // REFRESH
          // ----------------------------------------------------

          IconButton(
            onPressed: _refreshAccounts,
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: 'Refresh Accounts',
          ),

          // ----------------------------------------------------
          // TRANSFER
          // ----------------------------------------------------

          IconButton(
            onPressed: _openTransferScreen,
            icon: const Icon(
              Icons.swap_horiz,
            ),
            tooltip: 'Transfer Money',
          ),

          // ----------------------------------------------------
          // ADD ACCOUNT
          // ----------------------------------------------------

          IconButton(
            onPressed: _openAddAccount,
            icon: const Icon(
              Icons.add,
            ),
            tooltip: 'Add Account',
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Consumer<AccountProvider>(
        builder: (
          context,
          accountProvider,
          child,
        ) {
          final accounts = accountProvider.accounts;

          // ====================================================
          // LOADING
          // ====================================================

          if (accountProvider.isLoading &&
              accounts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // ==================================================
              // TOTAL BALANCE CARD
              // ==================================================

              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF1E3A8A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Account Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      '₹${accountProvider.totalAccountBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      '${accounts.length} accounts',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // ERROR MESSAGE
              // ==================================================

              if (accountProvider.errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          accountProvider.errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: _refreshAccounts,
                        icon: const Icon(
                          Icons.refresh,
                        ),
                      ),
                    ],
                  ),
                ),

              // ==================================================
              // ACCOUNT LIST
              // ==================================================

              Expanded(
                child: accounts.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _refreshAccounts,
                        child: ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(
                            bottom: 120,
                          ),
                          children: [
                            const SizedBox(
                              height: 70,
                            ),

                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 70,
                              color: Colors.grey,
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            const Center(
                              child: Text(
                                'No accounts added yet.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                ),
                                child: Text(
                                  'Tap the "Add Account" button below to create your first account.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            // ------------------------------------------------
                            // ADD ACCOUNT EMPTY STATE BUTTON
                            // ------------------------------------------------

                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _openAddAccount,
                                icon: const Icon(
                                  Icons.add,
                                ),
                                label: const Text(
                                  'Add Account',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshAccounts,
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 120,
                          ),
                          itemCount: accounts.length,
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            final account =
                                accounts[index];

                            return AccountCard(
                              account: account,

                              // --------------------------------
                              // EDIT
                              // --------------------------------

                              onEdit: () {
                                _openEditAccount(account);
                              },

                              // --------------------------------
                              // DELETE
                              // --------------------------------

                              onDelete: () {
                                _deleteAccount(
                                  context,
                                  account.id,
                                  account.name,
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),

      // ========================================================
      // ADD ACCOUNT BUTTON
      // ========================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _openAddAccount,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

