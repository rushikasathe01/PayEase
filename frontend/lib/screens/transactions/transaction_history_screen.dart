import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_card.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),

      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = provider.transactions;

          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 15),

                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Add your first transaction',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  key: ValueKey(transaction.id),

                  direction: DismissDirection.endToStart,

                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),

                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text(
                                'Delete Transaction?',
                              ),

                              content: const Text(
                                'This transaction will be permanently removed.',
                              ),

                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      dialogContext,
                                      false,
                                    );
                                  },
                                  child: const Text('Cancel'),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      dialogContext,
                                      true,
                                    );
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false;
                  },

                  onDismissed: (direction) async {
                    // Get logged-in user's JWT token.
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );

                    final token = authProvider.token;

                    // Check whether user is logged in.
                    if (token == null || token.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Session expired. Please login again.',
                          ),
                        ),
                      );

                      return;
                    }

                    // Delete transaction from backend.
                    final success = await provider.deleteTransaction(
                      token: token,
                      id: transaction.id,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Transaction deleted successfully',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.errorMessage ??
                                'Failed to delete transaction',
                          ),
                        ),
                      );
                    }
                  },

                  child: TransactionCard(
                    transaction: transaction,
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add-transaction',
          );
        },

        icon: const Icon(Icons.add),

        label: const Text('Add'),
      ),
    );
  }
}