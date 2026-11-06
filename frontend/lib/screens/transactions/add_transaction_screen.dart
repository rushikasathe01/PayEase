import 'package:flutter/material.dart';
import 'package:payeaseproject/providers/auth_provider.dart';
import 'package:payeaseproject/providers/account_provider.dart';
import 'package:provider/provider.dart';

import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // ============================================================
  // FORM
  // ============================================================

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  final TextEditingController _notesController =
      TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  TransactionType _selectedType =
      TransactionType.expense;

  String _selectedCategory = 'Food';

  String? _selectedAccountId;

  String _selectedPaymentMethod = 'UPI';

  DateTime _selectedDate = DateTime.now();

  bool _isSaving = false;

  // ============================================================
  // LISTS
  // ============================================================

  final List<String> _categories = [
    'Food',
    'Shopping',
    'Travel',
    'Bills',
    'Salary',
    'Freelance',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ];

  final List<String> _paymentMethods = [
    'UPI',
    'Cash',
    'Debit Card',
    'Credit Card',
    'Bank Transfer',
  ];

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAccounts();
    });
  }

  // ============================================================
  // LOAD REAL ACCOUNTS FROM BACKEND
  // ============================================================

  Future<void> _loadAccounts() async {
    if (!mounted) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    final token = authProvider.token;

    if (token == null || token.isEmpty) {
      return;
    }

    await accountProvider.loadAccounts(token);

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // SELECT FIRST REAL ACCOUNT
    // ----------------------------------------------------------

    if (accountProvider.accounts.isNotEmpty) {
      setState(() {
        _selectedAccountId =
            accountProvider.accounts.first.id;
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> _selectDate() async {
    final DateTime? pickedDate =
        await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // ============================================================
  // SAVE TRANSACTION
  // ============================================================

  Future<void> _saveTransaction() async {
    // ----------------------------------------------------------
    // VALIDATE FORM
    // ----------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ----------------------------------------------------------
    // CHECK ACCOUNT
    // ----------------------------------------------------------

    if (_selectedAccountId == null ||
        _selectedAccountId!.isEmpty) {
      _showErrorDialog(
        'Please select an account from My Accounts.',
      );

      return;
    }

    // ----------------------------------------------------------
    // GET AMOUNT
    // ----------------------------------------------------------

    final double? amount =
        double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      return;
    }

    // ----------------------------------------------------------
    // GET AUTH PROVIDER
    // ----------------------------------------------------------

    final AuthProvider authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    // ----------------------------------------------------------
    // GET JWT TOKEN
    // ----------------------------------------------------------

    final String? token =
        authProvider.token;

    // ----------------------------------------------------------
    // TOKEN CHECK
    // ----------------------------------------------------------

    if (token == null || token.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login again. Authentication token not found.',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // GET ACCOUNT PROVIDER
    // ----------------------------------------------------------

    final AccountProvider accountProvider =
        Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    // ----------------------------------------------------------
    // FIND SELECTED REAL ACCOUNT
    // ----------------------------------------------------------

    final selectedAccount =
        accountProvider.getAccountById(
      _selectedAccountId!,
    );

    if (selectedAccount == null) {
      _showErrorDialog(
        'Selected account was not found. '
        'Please refresh My Accounts and try again.',
      );

      return;
    }

    // ----------------------------------------------------------
    // CREATE TRANSACTION MODEL
    // ----------------------------------------------------------

    final TransactionModel transaction =
        TransactionModel(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      title: _titleController.text.trim(),

      amount: amount,

      type: _selectedType,

      category: _selectedCategory,

      date: _selectedDate,

      // IMPORTANT:
      // Store the REAL account name from MongoDB.
      account: selectedAccount.name,

      paymentMethod: _selectedPaymentMethod,

      notes: _notesController.text.trim(),
    );

    // ----------------------------------------------------------
    // GET TRANSACTION PROVIDER
    // ----------------------------------------------------------

    final TransactionProvider provider =
        Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    // ----------------------------------------------------------
    // START LOADING
    // ----------------------------------------------------------

    setState(() {
      _isSaving = true;
    });

    try {
      // --------------------------------------------------------
      // SEND TRANSACTION TO BACKEND
      // --------------------------------------------------------

      final bool success =
          await provider.addTransaction(
        token: token,
        transaction: transaction,
      );

      // --------------------------------------------------------
      // CHECK WIDGET
      // --------------------------------------------------------

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // STOP LOADING
      // --------------------------------------------------------

      setState(() {
        _isSaving = false;
      });

      // --------------------------------------------------------
      // FAILED
      // --------------------------------------------------------

      if (!success) {
        final String message =
            provider.errorMessage ??
                'Unable to add transaction.';

        _showErrorDialog(message);

        return;
      }

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transaction added successfully',
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // --------------------------------------------------------
      // GO BACK
      // --------------------------------------------------------

      Navigator.pop(context);
    } catch (e) {
      // --------------------------------------------------------
      // CHECK WIDGET
      // --------------------------------------------------------

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // STOP LOADING
      // --------------------------------------------------------

      setState(() {
        _isSaving = false;
      });

      _showErrorDialog(
        'Something went wrong: $e',
      );
    }
  }

  // ============================================================
  // ERROR DIALOG
  // ============================================================

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  'Transaction Failed',
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
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Transaction',
        ),
        centerTitle: true,
      ),

      body: Consumer<AccountProvider>(
        builder: (
          context,
          accountProvider,
          child,
        ) {
          // ====================================================
          // LOADING ACCOUNTS
          // ====================================================

          if (accountProvider.isLoading &&
              accountProvider.accounts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ====================================================
          // NO ACCOUNTS
          // ====================================================

          if (accountProvider.accounts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 70,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'No accounts found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Please create an account in My Accounts before adding a transaction.',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _loadAccounts,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label: const Text(
                        'Refresh Accounts',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ====================================================
          // NORMAL TRANSACTION FORM
          // ====================================================

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // TRANSACTION TYPE
                  // ==================================================

                  const Text(
                    'Transaction Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _typeButton(
                          title: 'Income',
                          icon: Icons.arrow_downward,
                          type: TransactionType.income,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _typeButton(
                          title: 'Expense',
                          icon: Icons.arrow_upward,
                          type: TransactionType.expense,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _typeButton(
                          title: 'Transfer',
                          icon: Icons.swap_horiz,
                          type: TransactionType.transfer,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  TextFormField(
                    controller: _titleController,

                    enabled: !_isSaving,

                    decoration:
                        const InputDecoration(
                      labelText: 'Title',
                      hintText:
                          'e.g. Grocery Shopping',
                      prefixIcon:
                          Icon(Icons.title),
                      border:
                          OutlineInputBorder(),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter title';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // AMOUNT
                  // ==================================================

                  TextFormField(
                    controller:
                        _amountController,

                    enabled: !_isSaving,

                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),

                    decoration:
                        const InputDecoration(
                      labelText: 'Amount',
                      hintText: 'Enter amount',
                      prefixIcon: Icon(
                        Icons.currency_rupee,
                      ),
                      border:
                          OutlineInputBorder(),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter amount';
                      }

                      final double? amount =
                          double.tryParse(
                        value.trim(),
                      );

                      if (amount == null ||
                          amount <= 0) {
                        return 'Enter a valid amount';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // CATEGORY
                  // ==================================================

                  DropdownButtonFormField<String>(
                    initialValue:
                        _selectedCategory,

                    decoration:
                        const InputDecoration(
                      labelText: 'Category',
                      prefixIcon:
                          Icon(Icons.category),
                      border:
                          OutlineInputBorder(),
                    ),

                    items:
                        _categories.map(
                      (category) {
                        return DropdownMenuItem<
                            String>(
                          value: category,
                          child:
                              Text(category),
                        );
                      },
                    ).toList(),

                    onChanged: _isSaving
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _selectedCategory =
                                  value;
                            });
                          },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // REAL DATABASE ACCOUNTS
                  // ==================================================

                  DropdownButtonFormField<String>(
                    value: _selectedAccountId,

                    decoration:
                        const InputDecoration(
                      labelText: 'Account',
                      prefixIcon: Icon(
                        Icons.account_balance,
                      ),
                      border:
                          OutlineInputBorder(),
                    ),

                    items:
                        accountProvider.accounts
                            .map(
                      (account) {
                        return DropdownMenuItem<
                            String>(
                          value: account.id,

                          child: Text(
                            account.name,
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: _isSaving
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _selectedAccountId =
                                  value;
                            });
                          },

                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Please select an account';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // PAYMENT METHOD
                  // ==================================================

                  DropdownButtonFormField<String>(
                    initialValue:
                        _selectedPaymentMethod,

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Payment Method',
                      prefixIcon:
                          Icon(Icons.payment),
                      border:
                          OutlineInputBorder(),
                    ),

                    items:
                        _paymentMethods.map(
                      (method) {
                        return DropdownMenuItem<
                            String>(
                          value: method,
                          child:
                              Text(method),
                        );
                      },
                    ).toList(),

                    onChanged: _isSaving
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _selectedPaymentMethod =
                                  value;
                            });
                          },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // DATE
                  // ==================================================

                  InkWell(
                    onTap:
                        _isSaving
                            ? null
                            : _selectDate,

                    child: InputDecorator(
                      decoration:
                          const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(
                          Icons.calendar_month,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),

                      child: Text(
                        _formatDate(
                          _selectedDate,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // NOTES
                  // ==================================================

                  TextFormField(
                    controller:
                        _notesController,

                    enabled: !_isSaving,

                    maxLines: 3,

                    decoration:
                        const InputDecoration(
                      labelText: 'Notes',
                      hintText:
                          'Add some notes',
                      prefixIcon:
                          Icon(Icons.notes),
                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // SAVE BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _isSaving
                              ? null
                              : _saveTransaction,

                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.check,
                            ),

                      label: Text(
                        _isSaving
                            ? 'Saving...'
                            : 'Save Transaction',

                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // TRANSACTION TYPE BUTTON
  // ============================================================

  Widget _typeButton({
    required String title,
    required IconData icon,
    required TransactionType type,
  }) {
    final bool isSelected =
        _selectedType == type;

    return GestureDetector(
      onTap: _isSaving
          ? null
          : () {
              setState(() {
                _selectedType = type;
              });
            },

      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 8,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context)
                  .colorScheme
                  .primary
              : Colors.grey.shade100,

          borderRadius:
              BorderRadius.circular(12),

          border: Border.all(
            color: isSelected
                ? Theme.of(context)
                    .colorScheme
                    .primary
                : Colors.grey.shade300,
          ),
        ),

        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Colors.grey.shade700,
            ),

            const SizedBox(height: 5),

            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.grey.shade700,

                fontWeight:
                    FontWeight.w600,

                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}