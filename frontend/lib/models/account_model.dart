enum AccountType { bank, cash, creditCard, upiWallet }

class AccountModel {
  final String id;
  final String name;
  final AccountType type;
  final String accountNumber;
  double balance;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.accountNumber,
    required this.balance,
  });

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    String? accountNumber,
    double? balance,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'accountNumber': accountNumber,
      'balance': balance,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: AccountType.values.firstWhere(
        (item) => item.name == map['type'],
        orElse: () => AccountType.bank,
      ),
      accountNumber: map['accountNumber'] as String? ?? '',
      balance: (map['balance'] as num).toDouble(),
    );
  }
}
