import 'package:flutter/material.dart';
import 'package:payeaseproject/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../models/account_model.dart';
import '../../providers/account_provider.dart';

class AddAccountScreen extends StatefulWidget {
  final AccountModel? account;

  const AddAccountScreen({
    super.key,
    this.account,
  });

  @override
  State<AddAccountScreen> createState() =>
      _AddAccountScreenState();
}

class _AddAccountScreenState
    extends State<AddAccountScreen> {
  // ============================================================
  // FORM
  // ============================================================

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _balanceController =
      TextEditingController();

  final TextEditingController _numberController =
      TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  AccountType _selectedType =
      AccountType.bank;

  bool get isEditing =>
      widget.account != null;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    if (widget.account != null) {
      _nameController.text =
          widget.account!.name;

      _balanceController.text =
          widget.account!.balance.toString();

      _numberController.text =
          widget.account!.accountNumber;

      _selectedType =
          widget.account!.type;
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _numberController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE ACCOUNT
  // ============================================================

  Future<void> _saveAccount() async {
    // ----------------------------------------------------------
    // VALIDATE FORM
    // ----------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ----------------------------------------------------------
    // GET BALANCE
    // ----------------------------------------------------------

    final double? balance =
        double.tryParse(
      _balanceController.text.trim(),
    );

    if (balance == null || balance < 0) {
      return;
    }

    // ----------------------------------------------------------
    // GET AUTH PROVIDER
    // ----------------------------------------------------------

    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final token =
        authProvider.token;

    // ----------------------------------------------------------
    // TOKEN CHECK
    // ----------------------------------------------------------

    if (token == null || token.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please login again.',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // GET ACCOUNT PROVIDER
    // ----------------------------------------------------------

    final provider =
        Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    bool success = false;

    // ==========================================================
    // EDIT ACCOUNT
    // ==========================================================

    if (isEditing) {
      final updatedAccount =
          widget.account!.copyWith(
        name:
            _nameController.text.trim(),

        type:
            _selectedType,

        balance:
            balance,

        accountNumber:
            _numberController.text.trim(),
      );

      success =
          await provider.updateAccount(
        token: token,
        account: updatedAccount,
      );
    }

    // ==========================================================
    // ADD ACCOUNT
    // ==========================================================

    else {
      final newAccount =
          AccountModel(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),

        name:
            _nameController.text.trim(),

        type:
            _selectedType,

        balance:
            balance,

        accountNumber:
            _numberController.text.trim(),
      );

      success =
          await provider.addAccount(
        token: token,
        account: newAccount,
      );
    }

    // ----------------------------------------------------------
    // CHECK WIDGET
    // ----------------------------------------------------------

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // SHOW RESULT
    // ----------------------------------------------------------

    if (!success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                (isEditing
                    ? 'Unable to update account'
                    : 'Unable to add account'),
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // SUCCESS MESSAGE
    // ----------------------------------------------------------

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Account updated successfully'
              : 'Account added successfully',
        ),
      ),
    );

    // ----------------------------------------------------------
    // GO BACK
    // ----------------------------------------------------------

    Navigator.pop(context);
  }

  // ============================================================
  // ACCOUNT TYPE NAME
  // ============================================================

  String _accountTypeName(
    AccountType type,
  ) {
    switch (type) {
      case AccountType.bank:
        return 'Bank Account';

      case AccountType.cash:
        return 'Cash';

      case AccountType.creditCard:
        return 'Credit Card';

      case AccountType.upiWallet:
        return 'UPI Wallet';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Account'
              : 'Add Account',
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // ACCOUNT TYPE
              // ==================================================

              const Text(
                'Account Type',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              DropdownButtonFormField<
                  AccountType>(
                initialValue:
                    _selectedType,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Select account type',

                  prefixIcon:
                      Icon(
                    Icons.account_balance,
                  ),
                ),

                items:
                    AccountType.values
                        .map(
                  (type) {
                    return DropdownMenuItem<
                        AccountType>(
                      value: type,

                      child: Text(
                        _accountTypeName(
                          type,
                        ),
                      ),
                    );
                  },
                ).toList(),

                onChanged:
                    (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedType =
                        value;
                  });
                },
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // ACCOUNT NAME
              // ==================================================

              TextFormField(
                controller:
                    _nameController,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Account Name',

                  hintText:
                      'e.g. SBI Bank Account',

                  prefixIcon:
                      Icon(
                    Icons.wallet,
                  ),
                ),

                validator:
                    (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Please enter account name';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // BALANCE
              // ==================================================

              TextFormField(
                controller:
                    _balanceController,

                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),

                decoration:
                    const InputDecoration(
                  labelText:
                      'Opening Balance',

                  hintText:
                      'Enter balance',

                  prefixIcon:
                      Icon(
                    Icons.currency_rupee,
                  ),
                ),

                validator:
                    (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Please enter balance';
                  }

                  final balance =
                      double.tryParse(
                    value.trim(),
                  );

                  if (balance == null ||
                      balance < 0) {
                    return
                        'Enter a valid balance';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // ACCOUNT NUMBER
              // ==================================================

              TextFormField(
                controller:
                    _numberController,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Account Number / Identifier',

                  hintText:
                      'e.g. **** 4582',

                  prefixIcon:
                      Icon(
                    Icons.numbers,
                  ),
                ),

                validator:
                    (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return
                        'Please enter identifier';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 30,
              ),

              // ==================================================
              // SAVE BUTTON
              // ==================================================

              SizedBox(
                width:
                    double.infinity,

                height: 55,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      _saveAccount,

                  icon: Icon(
                    isEditing
                        ? Icons.save
                        : Icons.add,
                  ),

                  label: Text(
                    isEditing
                        ? 'Update Account'
                        : 'Add Account',

                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}