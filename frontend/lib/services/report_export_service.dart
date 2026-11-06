
import 'dart:convert';
import 'dart:html' as html;
import '../models/account_model.dart';
import '../models/transaction_model.dart';

class ReportExportService {
  // ============================================================
  // EXPORT PAYEASE REPORT
  // ============================================================

  static void exportReport({
    required List<AccountModel> accounts,
    required List<TransactionModel> transactions,
  }) {
    final List<List<String>> rows = [];

    // ============================================================
    // REPORT TITLE
    // ============================================================

    rows.add([
      'PAYEASE FINANCIAL REPORT',
    ]);

    rows.add([]);

    // ============================================================
    // ACCOUNTS
    // ============================================================

    rows.add([
      'ACCOUNTS',
    ]);

    rows.add([
      'Account Name',
      'Account Type',
      'Account Number',
      'Balance',
    ]);

    for (final account in accounts) {
      rows.add([
        account.name,
        _accountType(account.type),
        account.accountNumber,
        account.balance.toStringAsFixed(2),
      ]);
    }

    // ============================================================
    // CALCULATE SUMMARY
    // ============================================================

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (final transaction in transactions) {
      if (transaction.type ==
          TransactionType.income) {
        totalIncome += transaction.amount;
      } else if (transaction.type ==
          TransactionType.expense) {
        totalExpense += transaction.amount;
      }
    }

    final double netSavings =
        totalIncome - totalExpense;

    // ============================================================
    // SUMMARY
    // ============================================================

    rows.add([]);

    rows.add([
      'SUMMARY',
    ]);

    rows.add([
      'Total Income',
      totalIncome.toStringAsFixed(2),
    ]);

    rows.add([
      'Total Expense',
      totalExpense.toStringAsFixed(2),
    ]);

    rows.add([
      'Net Savings',
      netSavings.toStringAsFixed(2),
    ]);

    // ============================================================
    // TRANSACTIONS
    // ============================================================

    rows.add([]);

    rows.add([
      'TRANSACTIONS',
    ]);

    rows.add([
      'Date',
      'Title',
      'Type',
      'Category',
      'Amount',
      'Account',
      'Payment Method',
      'Notes',
    ]);

    for (final transaction in transactions) {
      rows.add([
        _formatDate(transaction.date),
        transaction.title,
        _transactionType(transaction.type),
        transaction.category,
        transaction.amount.toStringAsFixed(2),
        transaction.account,
        transaction.paymentMethod,
        transaction.notes,
      ]);
    }

    // ============================================================
    // CONVERT ROWS TO CSV
    // ============================================================

    final String csvData =
        _convertToCsv(rows);

    // ============================================================
    // CREATE BROWSER FILE
    // ============================================================

    final List<int> bytes =
        utf8.encode(csvData);

    final html.Blob blob = html.Blob(
      [bytes],
      'text/csv;charset=utf-8',
    );

    // ============================================================
    // CREATE DOWNLOAD URL
    // ============================================================

    final String url =
        html.Url.createObjectUrlFromBlob(blob);

    // ============================================================
    // DOWNLOAD FILE
    // ============================================================

    final html.AnchorElement anchor =
        html.AnchorElement(
      href: url,
    );

    anchor.setAttribute(
      'download',
      'payease_report.csv',
    );

    anchor.click();

    // ============================================================
    // CLEAN URL
    // ============================================================

    html.Url.revokeObjectUrl(url);
  }

  // ============================================================
  // CSV CONVERTER
  // ============================================================

  static String _convertToCsv(
    List<List<String>> rows,
  ) {
    final StringBuffer csv =
        StringBuffer();

    for (final row in rows) {
      final List<String> escapedRow = [];

      for (final value in row) {
        escapedRow.add(
          _escapeCsvValue(value),
        );
      }

      csv.writeln(
        escapedRow.join(','),
      );
    }

    return csv.toString();
  }

  // ============================================================
  // ESCAPE CSV VALUE
  // ============================================================

  static String _escapeCsvValue(
    String value,
  ) {
    // CSV requires quotes when a value contains:
    // comma, double quote, or newline.

    final bool needsQuotes =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');

    if (!needsQuotes) {
      return value;
    }

    // Double quotes inside CSV values
    // must be escaped by doubling them.

    final String escaped =
        value.replaceAll(
      '"',
      '""',
    );

    return '"$escaped"';
  }

  // ============================================================
  // ACCOUNT TYPE
  // ============================================================

  static String _accountType(
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
  // TRANSACTION TYPE
  // ============================================================

  static String _transactionType(
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
  // DATE FORMAT
  // ============================================================

  static String _formatDate(
    DateTime date,
  ) {
    final String day =
        date.day.toString().padLeft(2, '0');

    final String month =
        date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }
}

