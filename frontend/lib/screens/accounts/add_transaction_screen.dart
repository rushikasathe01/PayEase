import 'package:flutter/material.dart';
import 'package:payeaseproject/providers/auth_provider.dart';
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  DateTime _selectedDate = DateTime.now();

  String _selectedCategory = 'Food';

  TransactionType _selectedType = TransactionType.expense;

  String _selectedAccount = 'Bank Account';

  String _selectedPaymentMethod = 'UPI';

  // ============================================================
  // LISTS
  // ============================================================

  final List<String> _categories = [
    'Food',
    'Shopping',
    'Bills',
    'Salary',
    'Freelance',
    'Transport',
    'Entertainment',
    'Healthcare',
    'Education',
    'Other',
  ];

  final List<String> _accounts = [
    'Bank Account',
    'Cash',
    'Credit Card',
    'UPI Wallet',
  ];

  final List<String> _paymentMethods = [
    'UPI',
    'Cash',
    'Bank Transfer',
    'Card',
  ];

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
    final DateTime? pickedDate = await showDatePicker(
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
    // GET AMOUNT
    // ----------------------------------------------------------

    final double? amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      return;
    }

    // ----------------------------------------------------------
    // CREATE TRANSACTION
    // ----------------------------------------------------------

    final TransactionModel transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      type: _selectedType,
      account: _selectedAccount,
      paymentMethod: _selectedPaymentMethod,
      notes: _notesController.text.trim(),
    );

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

    final String? token = authProvider.token;

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
    // GET TRANSACTION PROVIDER
    // ----------------------------------------------------------

    final TransactionProvider provider =
        Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    // ----------------------------------------------------------
    // ADD TRANSACTION THROUGH BACKEND
    // ----------------------------------------------------------

    final bool success = await provider.addTransaction(
      token: token,
      transaction: transaction,
    );

    // ----------------------------------------------------------
    // CHECK WIDGET
    // ----------------------------------------------------------

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // TRANSACTION FAILED
    // ----------------------------------------------------------

    if (!success) {
      _showErrorDialog(
        provider.errorMessage ??
            'Unable to add transaction.',
      );

      return;
    }

    // ----------------------------------------------------------
    // SUCCESS MESSAGE
    // ----------------------------------------------------------

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Transaction added successfully',
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // ----------------------------------------------------------
    // GO BACK
    // ----------------------------------------------------------

    Navigator.pop(context);
  }

  // ============================================================
  // ERROR DIALOG
  // ============================================================

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
              Expanded(
                child: Text(
                  'Transaction Failed',
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // HEADING
                // ==================================================

                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // TITLE
                // ==================================================

                TextFormField(
                  controller: _titleController,

                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter transaction title',

                    prefixIcon: const Icon(
                      Icons.title,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter a title';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // AMOUNT
                // ==================================================

                TextFormField(
                  controller: _amountController,

                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter amount',

                    prefixText: '₹ ',

                    prefixIcon: const Icon(
                      Icons.currency_rupee,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter amount';
                    }

                    final double? amount =
                        double.tryParse(value.trim());

                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // TRANSACTION TYPE
                // ==================================================

                DropdownButtonFormField<TransactionType>(
                  initialValue: _selectedType,

                  decoration: InputDecoration(
                    labelText: 'Transaction Type',

                    prefixIcon: const Icon(
                      Icons.swap_vert,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  items: const [
                    DropdownMenuItem(
                      value: TransactionType.income,
                      child: Text('Income'),
                    ),

                    DropdownMenuItem(
                      value: TransactionType.expense,
                      child: Text('Expense'),
                    ),
                  ],

                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // CATEGORY
                // ==================================================

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,

                  decoration: InputDecoration(
                    labelText: 'Category',

                    prefixIcon: const Icon(
                      Icons.category_outlined,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  items: _categories.map(
                    (category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    },
                  ).toList(),

                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // ACCOUNT
                // ==================================================

                DropdownButtonFormField<String>(
                  initialValue: _selectedAccount,

                  decoration: InputDecoration(
                    labelText: 'Account',

                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_outlined,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  items: _accounts.map(
                    (account) {
                      return DropdownMenuItem<String>(
                        value: account,
                        child: Text(account),
                      );
                    },
                  ).toList(),

                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedAccount = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // PAYMENT METHOD
                // ==================================================

                DropdownButtonFormField<String>(
                  initialValue: _selectedPaymentMethod,

                  decoration: InputDecoration(
                    labelText: 'Payment Method',

                    prefixIcon: const Icon(
                      Icons.payment,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  items: _paymentMethods.map(
                    (method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    },
                  ).toList(),

                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // DATE
                // ==================================================

                InkWell(
                  onTap: _selectDate,

                  borderRadius: BorderRadius.circular(12),

                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',

                      prefixIcon: const Icon(
                        Icons.calendar_today,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/'
                      '${_selectedDate.month.toString().padLeft(2, '0')}/'
                      '${_selectedDate.year}',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // NOTES
                // ==================================================

                TextFormField(
                  controller: _notesController,

                  maxLines: 3,

                  decoration: InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Add additional notes',

                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(
                        bottom: 45,
                      ),

                      child: Icon(
                        Icons.notes,
                      ),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // ADD TRANSACTION BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton.icon(
                    onPressed: _saveTransaction,

                    icon: const Icon(
                      Icons.add,
                    ),

                    label: const Text(
                      'Add Transaction',

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}