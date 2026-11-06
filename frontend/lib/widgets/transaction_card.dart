import 'package:flutter/material.dart';

import '../models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({super.key, required this.transaction});

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Salary':
        return Icons.work;
      case 'Freelance':
        return Icons.laptop;
      case 'Travel':
        return Icons.flight;
      case 'Bills':
        return Icons.receipt;
      case 'Health':
        return Icons.favorite;
      case 'Education':
        return Icons.school;
      case 'Entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == TransactionType.income;

    final bool isTransfer = transaction.type == TransactionType.transfer;

    final Color amountColor = isIncome
        ? Colors.green
        : isTransfer
        ? Colors.blue
        : Colors.red;

    final String amountPrefix = isIncome
        ? '+'
        : isTransfer
        ? ''
        : '-';

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),

            child: Icon(
              _getCategoryIcon(transaction.category),
              color: amountColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${transaction.category} • ${transaction.paymentMethod}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 3),

                Text(
                  _formatDate(transaction.date),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),

          Text(
            '$amountPrefix₹${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
