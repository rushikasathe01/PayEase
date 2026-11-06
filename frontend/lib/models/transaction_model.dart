enum TransactionType { income, expense, transfer }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;
  final String account;
  final String paymentMethod;
  final String notes;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    required this.account,
    required this.paymentMethod,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type.name,
      'account': account,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      type: TransactionType.values.firstWhere(
        (item) => item.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      account: map['account'] as String,
      paymentMethod: map['paymentMethod'] as String,
      notes: map['notes'] as String? ?? '',
    );
  }
}
