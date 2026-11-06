import 'package:flutter/material.dart';

import '../models/account_model.dart';
import '../services/api_service.dart';

class AccountProvider extends ChangeNotifier {
  final List<AccountModel> _accounts = [];

  bool _isLoading = false;
  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<AccountModel> get accounts {
    return List.unmodifiable(_accounts);
  }

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // LOAD ACCOUNTS FROM BACKEND
  // ============================================================

  Future<void> loadAccounts(String token) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      final response = await ApiService.getAccounts(token);

      if (response['success'] != true) {
        _errorMessage =
            response['message']?.toString() ??
            'Unable to load accounts';

        _isLoading = false;

        notifyListeners();

        return;
      }

      final List<dynamic> data =
          response['accounts'] ?? [];

      _accounts.clear();

      for (final item in data) {
        if (item is Map) {
          _accounts.add(
            _accountFromBackend(
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
  // CREATE ACCOUNT
  // ============================================================

  Future<bool> addAccount({
    required String token,
    required AccountModel account,
  }) async {
    try {
      _errorMessage = null;

      final response = await ApiService.createAccount(
        token: token,
        name: account.name,
        type: _accountTypeToBackend(account.type),
        balance: account.balance,
        accountNumber: account.accountNumber,
      );

      if (response['success'] != true) {
        _errorMessage =
            response['message']?.toString() ??
            'Unable to create account';

        notifyListeners();

        return false;
      }

      final createdAccount =
          response['account'];

      if (createdAccount != null &&
          createdAccount is Map) {
        _accounts.add(
          _accountFromBackend(
            Map<String, dynamic>.from(
              createdAccount,
            ),
          ),
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // UPDATE ACCOUNT
  // ============================================================

  Future<bool> updateAccount({
    required String token,
    required AccountModel account,
  }) async {
    try {
      _errorMessage = null;

      final response = await ApiService.updateAccount(
        token: token,
        accountId: account.id,
        name: account.name,
        type: _accountTypeToBackend(account.type),
        balance: account.balance,
        accountNumber: account.accountNumber,
      );

      if (response['success'] != true) {
        _errorMessage =
            response['message']?.toString() ??
            'Unable to update account';

        notifyListeners();

        return false;
      }

      final updatedAccount =
          response['account'];

      if (updatedAccount != null &&
          updatedAccount is Map) {
        final newAccount =
            _accountFromBackend(
          Map<String, dynamic>.from(
            updatedAccount,
          ),
        );

        final index =
            _accounts.indexWhere(
          (item) => item.id == account.id,
        );

        if (index != -1) {
          _accounts[index] = newAccount;
        }
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<bool> deleteAccount({
    required String token,
    required String id,
  }) async {
    try {
      _errorMessage = null;

      final response =
          await ApiService.deleteAccount(
        token: token,
        accountId: id,
      );

      if (response['success'] != true) {
        _errorMessage =
            response['message']?.toString() ??
            'Unable to delete account';

        notifyListeners();

        return false;
      }

      _accounts.removeWhere(
        (account) => account.id == id,
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
  // TRANSFER MONEY
  // ============================================================

  Future<bool> transferMoney({
    required String token,
    required String fromAccountId,
    required String toAccountId,
    required double amount,
  }) async {
    try {
      _errorMessage = null;

      // ----------------------------------------------------------
      // VALIDATE ACCOUNT IDS
      // ----------------------------------------------------------

      if (fromAccountId == toAccountId) {
        _errorMessage =
            'From and To accounts must be different.';

        notifyListeners();

        return false;
      }

      // ----------------------------------------------------------
      // VALIDATE AMOUNT
      // ----------------------------------------------------------

      if (amount <= 0) {
        _errorMessage =
            'Transfer amount must be greater than zero.';

        notifyListeners();

        return false;
      }

      // ----------------------------------------------------------
      // FIND SOURCE ACCOUNT
      // ----------------------------------------------------------

      final sourceAccount =
          getAccountById(fromAccountId);

      if (sourceAccount == null) {
        _errorMessage =
            'Source account not found.';

        notifyListeners();

        return false;
      }

      // ----------------------------------------------------------
      // FIND DESTINATION ACCOUNT
      // ----------------------------------------------------------

      final destinationAccount =
          getAccountById(toAccountId);

      if (destinationAccount == null) {
        _errorMessage =
            'Destination account not found.';

        notifyListeners();

        return false;
      }

      // ----------------------------------------------------------
      // CHECK BALANCE
      // ----------------------------------------------------------

      if (sourceAccount.balance < amount) {
        _errorMessage =
            'Insufficient balance in ${sourceAccount.name}.';

        notifyListeners();

        return false;
      }

      // ----------------------------------------------------------
      // START LOADING
      // ----------------------------------------------------------

      _isLoading = true;

      notifyListeners();

      // ----------------------------------------------------------
      // CALL BACKEND
      // ----------------------------------------------------------

      final response =
          await ApiService.transferMoney(
        token: token,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
      );

      // ----------------------------------------------------------
      // CHECK BACKEND RESPONSE
      // ----------------------------------------------------------

      if (response['success'] != true) {
        _errorMessage =
            response['message']?.toString() ??
            'Unable to transfer money.';

        _isLoading = false;

        notifyListeners();

        return false;
      }

      // ----------------------------------------------------------
      // BACKEND MAY RETURN UPDATED ACCOUNTS
      // ----------------------------------------------------------

      final updatedAccounts =
          response['accounts'];

      if (updatedAccounts is List) {
        _accounts.clear();

        for (final item in updatedAccounts) {
          if (item is Map) {
            _accounts.add(
              _accountFromBackend(
                Map<String, dynamic>.from(item),
              ),
            );
          }
        }
      } else {
        // --------------------------------------------------------
        // IF TRANSFER RESPONSE DOES NOT RETURN ACCOUNTS,
        // LOAD ACCOUNTS AGAIN FROM DATABASE.
        // --------------------------------------------------------

        final accountsResponse =
            await ApiService.getAccounts(token);

        if (accountsResponse['success'] == true) {
          final List<dynamic> data =
              accountsResponse['accounts'] ?? [];

          _accounts.clear();

          for (final item in data) {
            if (item is Map) {
              _accounts.add(
                _accountFromBackend(
                  Map<String, dynamic>.from(item),
                ),
              );
            }
          }
        }
      }

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      _isLoading = false;
      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _cleanError(e);

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // TOTAL BALANCE
  // ============================================================

  double get totalAccountBalance {
    return _accounts.fold(
      0.0,
      (sum, account) =>
          sum + account.balance,
    );
  }

  // ============================================================
  // FIND ACCOUNT
  // ============================================================

  AccountModel? getAccountById(String id) {
    try {
      return _accounts.firstWhere(
        (account) => account.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // CONVERT BACKEND ACCOUNT → FLUTTER MODEL
  // ============================================================

  AccountModel _accountFromBackend(
    Map<String, dynamic> data,
  ) {
    return AccountModel(
      id: data['_id']?.toString() ??
          data['id']?.toString() ??
          '',
      name: data['name']?.toString() ?? '',
      type: _accountTypeFromBackend(
        data['type']?.toString() ?? 'Bank',
      ),
      accountNumber:
          data['accountNumber']?.toString() ?? '',
      balance: _toDouble(
        data['balance'],
      ),
    );
  }

  // ============================================================
  // FLUTTER ACCOUNT TYPE → BACKEND TYPE
  // ============================================================

  String _accountTypeToBackend(
    AccountType type,
  ) {
    switch (type) {
      case AccountType.bank:
        return 'Bank';

      case AccountType.cash:
        return 'Cash';

      case AccountType.creditCard:
        return 'Credit Card';

      case AccountType.upiWallet:
        return 'UPI Wallet';
    }
  }

  // ============================================================
  // BACKEND TYPE → FLUTTER ACCOUNT TYPE
  // ============================================================

  AccountType _accountTypeFromBackend(
    String type,
  ) {
    switch (type) {
      case 'Bank':
        return AccountType.bank;

      case 'Cash':
        return AccountType.cash;

      case 'Credit Card':
        return AccountType.creditCard;

      case 'UPI Wallet':
        return AccountType.upiWallet;

      default:
        return AccountType.bank;
    }
  }

  // ============================================================
  // DOUBLE CONVERSION
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
  // ERROR CLEANING
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}