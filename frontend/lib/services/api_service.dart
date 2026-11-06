import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // ============================================================
  // SIGNUP
  // ============================================================

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  static Future<Map<String, dynamic>> getMe(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  // ============================================================
  // GET ACCOUNTS
  // ============================================================

  static Future<Map<String, dynamic>> getAccounts(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/accounts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  // ============================================================
  // GET TRANSACTIONS
  // ============================================================

  static Future<Map<String, dynamic>> getTransactions(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  static Future<Map<String, dynamic>> createAccount({
    required String token,
    required String name,
    required String type,
    required double balance,
    String accountNumber = '',
    String description = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'type': type,
        'balance': balance,
        'accountNumber': accountNumber,
        'description': description,
      }),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // UPDATE ACCOUNT
  // ============================================================

  static Future<Map<String, dynamic>> updateAccount({
    required String token,
    required String accountId,
    required String name,
    required String type,
    required double balance,
    String accountNumber = '',
    String description = '',
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/accounts/$accountId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'type': type,
        'balance': balance,
        'accountNumber': accountNumber,
        'description': description,
      }),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  static Future<Map<String, dynamic>> deleteAccount({
    required String token,
    required String accountId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/accounts/$accountId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  // ============================================================
  // TRANSFER MONEY
  // ============================================================

  static Future<Map<String, dynamic>> transferMoney({
    required String token,
    required String fromAccountId,
    required String toAccountId,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts/transfer'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
      }),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // CREATE TRANSACTION
  // ============================================================

  static Future<Map<String, dynamic>> createTransaction({
    required String token,
    required String title,
    required double amount,
    required String type,
    required String category,
    required String date,
    required String accountId,
    String notes = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'date': date,
        'accountId': accountId,
        'notes': notes,
      }),
    );

    return _handleResponse(response);
  }

  // ============================================================
  // DELETE TRANSACTION
  // ============================================================

  static Future<Map<String, dynamic>> deleteTransaction({
    required String token,
    required String transactionId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/$transactionId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  // ============================================================
  // HANDLE RESPONSE
  // ============================================================

  static Map<String, dynamic> _handleResponse(
    http.Response response,
  ) {
    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      throw Exception(
        'Invalid server response (${response.statusCode})',
      );
    }

    final Map<String, dynamic> data =
        decoded is Map<String, dynamic>
            ? decoded
            : <String, dynamic>{};

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message']?.toString() ??
          'Something went wrong (${response.statusCode})',
    );
  }
}