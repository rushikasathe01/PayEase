import 'package:flutter/material.dart';

import '../models/account_model.dart';

class AccountCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AccountCard({
    super.key,
    required this.account,
    this.onEdit,
    this.onDelete,
  });

  IconData _getIcon(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Icons.account_balance;

      case AccountType.cash:
        return Icons.payments;

      case AccountType.creditCard:
        return Icons.credit_card;

      case AccountType.upiWallet:
        return Icons.account_balance_wallet;
    }
  }

  Color _getColor(AccountType type) {
    switch (type) {
      case AccountType.bank:
        return Colors.blue;

      case AccountType.cash:
        return Colors.green;

      case AccountType.creditCard:
        return Colors.orange;

      case AccountType.upiWallet:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(account.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: const Color(0xFFE2E8F0)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),

            child: Icon(_getIcon(account.type), color: color, size: 26),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  account.accountNumber,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  '₹${account.balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit?.call();
              }

              if (value == 'delete') {
                onDelete?.call();
              }
            },

            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Delete'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
