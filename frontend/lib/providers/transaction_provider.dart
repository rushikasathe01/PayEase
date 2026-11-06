import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../services/api_service.dart';

class TransactionProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];

  bool _isLoading = false;
  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<TransactionModel> get transactions {
    return List.unmodifiable(_transactions);
  }

  int get transactionCount {
    return _transactions.length;
  }

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // LOAD TRANSACTIONS FROM BACKEND
  // ============================================================

  Future<void> loadTransactions(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      // Clear previous user's transactions.
      _transactions.clear();

      notifyListeners();

      final response = await ApiService.getTransactions(token);

      if (response['success'] != true) {
        _errorMessage =
            response['message'] ?? 'Unable to load transactions';

        _isLoading = false;
        notifyListeners();
        return;
      }

      final List<dynamic> data = response['transactions'] ?? [];

      _transactions.clear();

      for (final item in data) {
        if (item is Map) {
          _transactions.add(
            _transactionFromBackend(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanError(e);
      notifyListeners();
    }
  }

  // ============================================================
  // ADD TRANSACTION
  // ============================================================

  Future<bool> addTransaction({
    required String token,
    required TransactionModel transaction,
  }) async {
    try {
      _errorMessage = null;

      // ----------------------------------------------------------
      // GET USER ACCOUNTS FROM BACKEND
      // ----------------------------------------------------------

      final accountsResponse = await ApiService.getAccounts(token);

      if (accountsResponse['success'] != true) {
        _errorMessage =
            accountsResponse['message'] ?? 'Unable to load accounts';

        notifyListeners();
        return false;
      }

      final List<dynamic> accounts =
          accountsResponse['accounts'] ?? [];

      // ----------------------------------------------------------
      // DEBUG INFORMATION
      // ----------------------------------------------------------

      debugPrint(
        'Selected transaction account: "${transaction.account}"',
      );

      debugPrint(
        'Backend accounts count: ${accounts.length}',
      );

      // ----------------------------------------------------------
      // FIND SELECTED ACCOUNT
      // ----------------------------------------------------------

      String? accountId;

      for (final item in accounts) {
        if (item is! Map) {
          continue;
        }

        final account = Map<String, dynamic>.from(item);

        final backendId =
            account['_id']?.toString() ??
            account['id']?.toString() ??
            '';

        final backendName =
            account['name']?.toString() ?? '';

        final selectedValue =
            transaction.account.toString();

        // Normalize values.
        final normalizedBackendId =
            _normalize(backendId);

        final normalizedBackendName =
            _normalize(backendName);

        final normalizedSelectedValue =
            _normalize(selectedValue);

        debugPrint(
          'Checking account -> '
          'id: "$backendId", '
          'name: "$backendName"',
        );

        // --------------------------------------------------------
        // MATCH BY MONGODB ID
        // --------------------------------------------------------

        if (normalizedBackendId.isNotEmpty &&
            normalizedBackendId ==
                normalizedSelectedValue) {
          accountId = backendId;

          debugPrint(
            'Account matched by ID: $accountId',
          );

          break;
        }

        // --------------------------------------------------------
        // MATCH BY ACCOUNT NAME
        // --------------------------------------------------------

        if (normalizedBackendName.isNotEmpty &&
            normalizedBackendName ==
                normalizedSelectedValue) {
          accountId = backendId;

          debugPrint(
            'Account matched by name: '
            '$backendName -> $accountId',
          );

          break;
        }
      }

      // ----------------------------------------------------------
      // ACCOUNT NOT FOUND
      // ----------------------------------------------------------

      if (accountId == null || accountId.isEmpty) {
        _errorMessage =
            'Selected account was not found. '
            'Please select an account that exists in My Accounts.';

        debugPrint(
          'ERROR: Selected account was not found.',
        );

        debugPrint(
          'Flutter selected account: '
          '"${transaction.account}"',
        );

        notifyListeners();
        return false;
      }

      // ----------------------------------------------------------
      // CREATE TRANSACTION ON BACKEND
      // ----------------------------------------------------------

      debugPrint(
        'Creating transaction using accountId: $accountId',
      );

      final response = await ApiService.createTransaction(
        token: token,
        title: transaction.title,
        amount: transaction.amount,
        type: _transactionTypeToBackend(
          transaction.type,
        ),
        category: transaction.category,
        date: transaction.date.toIso8601String(),
        accountId: accountId,
        notes: transaction.notes,
      );

      // ----------------------------------------------------------
      // BACKEND ERROR
      // ----------------------------------------------------------

      if (response['success'] != true) {
        _errorMessage =
            response['message'] ??
            'Unable to create transaction';

        notifyListeners();
        return false;
      }

      // ----------------------------------------------------------
      // GET CREATED TRANSACTION
      // ----------------------------------------------------------

      final createdTransaction =
          response['transaction'];

      if (createdTransaction != null &&
          createdTransaction is Map) {
        _transactions.insert(
          0,
          _transactionFromBackend(
            Map<String, dynamic>.from(
              createdTransaction,
            ),
          ),
        );

        notifyListeners();

        return true;
      }

      // ----------------------------------------------------------
      // FALLBACK
      // ----------------------------------------------------------

      await loadTransactions(token);

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      debugPrint(
        'Add transaction error: $_errorMessage',
      );

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================

  Future<bool> deleteTransaction({
    required String token,
    required String id,
  }) async {
    try {
      _errorMessage = null;

      final response =
          await ApiService.deleteTransaction(
        token: token,
        transactionId: id,
      );

      if (response['success'] != true) {
        _errorMessage =
            response['message'] ??
            'Unable to delete transaction';

        notifyListeners();

        return false;
      }

      _transactions.removeWhere(
        (transaction) => transaction.id == id,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // CONVERT BACKEND DATA TO TRANSACTION MODEL
  // ============================================================

  TransactionModel _transactionFromBackend(
    Map<String, dynamic> data,
  ) {
    String accountName = '';

    final accountData = data['accountId'];

    // ----------------------------------------------------------
    // ACCOUNT ID IS POPULATED OBJECT
    // ----------------------------------------------------------

    if (accountData is Map) {
      accountName =
          accountData['name']?.toString() ?? '';
    }

    // ----------------------------------------------------------
    // ACCOUNT OBJECT
    // ----------------------------------------------------------

    else if (data['account'] is Map) {
      final account =
          Map<String, dynamic>.from(
        data['account'],
      );

      accountName =
          account['name']?.toString() ?? '';
    }

    // ----------------------------------------------------------
    // ACCOUNT NAME DIRECTLY AVAILABLE
    // ----------------------------------------------------------

    else {
      accountName =
          data['accountName']?.toString() ?? '';
    }

    // ----------------------------------------------------------
    // CREATE TRANSACTION MODEL
    // ----------------------------------------------------------

    return TransactionModel(
      id: data['_id']?.toString() ??
          data['id']?.toString() ??
          '',

      title:
          data['title']?.toString() ?? '',

      amount:
          _toDouble(data['amount']),

      date:
          DateTime.tryParse(
                data['date']?.toString() ?? '',
              ) ??
              DateTime.now(),

      category:
          data['category']?.toString() ?? '',

      type:
          _transactionTypeFromBackend(
        data['type']?.toString() ?? 'Expense',
      ),

      account:
          accountName,

      paymentMethod:
          data['paymentMethod']?.toString() ?? '',

      notes:
          data['notes']?.toString() ?? '',
    );
  }

  // ============================================================
  // TRANSACTION TYPE
  // ============================================================

  String _transactionTypeToBackend(
    TransactionType type,
  ) {
    switch (type) {
      case TransactionType.income:
        return 'Income';

      case TransactionType.expense:
        return 'Expense';

      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  // ============================================================
  // BACKEND TYPE TO FLUTTER TYPE
  // ============================================================

  TransactionType _transactionTypeFromBackend(
    String type,
  ) {
    switch (type.toLowerCase()) {
      case 'income':
        return TransactionType.income;

      case 'transfer':
        return TransactionType.transfer;

      case 'expense':
      default:
        return TransactionType.expense;
    }
  }

  // ============================================================
  // TOTAL INCOME
  // ============================================================

  double get totalIncome {
    return _transactions
        .where(
          (transaction) =>
              transaction.type ==
              TransactionType.income,
        )
        .fold(
          0.0,
          (sum, transaction) =>
              sum + transaction.amount,
        );
  }

  // ============================================================
  // TOTAL EXPENSE
  // ============================================================

  double get totalExpense {
    return _transactions
        .where(
          (transaction) =>
              transaction.type ==
              TransactionType.expense,
        )
        .fold(
          0.0,
          (sum, transaction) =>
              sum + transaction.amount,
        );
  }

  // ============================================================
  // TOTAL BALANCE
  // ============================================================

  double get balance {
    final currentBalance =
        totalIncome - totalExpense;

    if (currentBalance < 0) {
      return 0.0;
    }

    return currentBalance;
  }

  // ============================================================
  // SAVINGS
  // ============================================================

  double get savings {
    return balance;
  }

  // ============================================================
  // SAVINGS RATE
  // ============================================================

  double get savingsRate {
    if (totalIncome == 0) {
      return 0.0;
    }

    return (savings / totalIncome) * 100;
  }

  // ============================================================
  // ACCOUNT-WISE BALANCE
  // ============================================================

  double getAccountBalance(
    String accountName,
  ) {
    double income = 0.0;
    double expense = 0.0;

    for (final transaction in _transactions) {
      if (transaction.account != accountName) {
        continue;
      }

      if (transaction.type ==
          TransactionType.income) {
        income += transaction.amount;
      } else if (transaction.type ==
          TransactionType.expense) {
        expense += transaction.amount;
      }
    }

    final accountBalance =
        income - expense;

    if (accountBalance < 0) {
      return 0.0;
    }

    return accountBalance;
  }

  // ============================================================
  // ACCOUNT-WISE INCOME
  // ============================================================

  double getAccountIncome(
    String accountName,
  ) {
    return _transactions
        .where(
          (transaction) =>
              transaction.account ==
                  accountName &&
              transaction.type ==
                  TransactionType.income,
        )
        .fold(
          0.0,
          (sum, transaction) =>
              sum + transaction.amount,
        );
  }

  // ============================================================
  // ACCOUNT-WISE EXPENSE
  // ============================================================

  double getAccountExpense(
    String accountName,
  ) {
    return _transactions
        .where(
          (transaction) =>
              transaction.account ==
                  accountName &&
              transaction.type ==
                  TransactionType.expense,
        )
        .fold(
          0.0,
          (sum, transaction) =>
              sum + transaction.amount,
        );
  }

  // ============================================================
  // CATEGORY EXPENSES
  // ============================================================

  Map<String, double> get categoryExpenses {
    final Map<String, double> result = {};

    for (final transaction in _transactions) {
      if (transaction.type ==
          TransactionType.expense) {
        result[transaction.category] =
            (result[transaction.category] ?? 0.0) +
            transaction.amount;
      }
    }

    return result;
  }

  // ============================================================
  // MONTHLY INCOME
  // ============================================================

  Map<String, double> get monthlyIncome {
    final Map<String, double> result = {};

    for (final transaction in _transactions) {
      if (transaction.type ==
          TransactionType.income) {
        final month =
            transaction.date.month.toString();

        result[month] =
            (result[month] ?? 0.0) +
            transaction.amount;
      }
    }

    return result;
  }

  // ============================================================
  // MONTHLY EXPENSES
  // ============================================================

  Map<String, double> get monthlyExpenses {
    final Map<String, double> result = {};

    for (final transaction in _transactions) {
      if (transaction.type ==
          TransactionType.expense) {
        final month =
            transaction.date.month.toString();

        result[month] =
            (result[month] ?? 0.0) +
            transaction.amount;
      }
    }

    return result;
  }

  // ============================================================
  // MONTHLY SAVINGS
  // ============================================================

  Map<String, double> get monthlySavings {
    final Map<String, double> result = {};

    final months = {
      ...monthlyIncome.keys,
      ...monthlyExpenses.keys,
    };

    for (final month in months) {
      final income =
          monthlyIncome[month] ?? 0.0;

      final expense =
          monthlyExpenses[month] ?? 0.0;

      result[month] =
          income - expense;
    }

    return result;
  }

  // ============================================================
  // NORMALIZE ACCOUNT VALUE
  // ============================================================

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase();
  }

  // ============================================================
  // CONVERT TO DOUBLE
  // ============================================================

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  // ============================================================
  // CLEAN ERROR MESSAGE
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }

  // ============================================================
  // CLEAR USER DATA
  // ============================================================

  void clearTransactions() {
    _transactions.clear();

    _errorMessage = null;

    notifyListeners();
  }
}