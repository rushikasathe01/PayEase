import 'package:flutter/material.dart';
import 'package:payeaseproject/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/account_provider.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  // ============================================================
  // FORM
  // ============================================================

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  // ============================================================
  // CONTROLLER
  // ============================================================

  final TextEditingController _amountController =
      TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  String? _fromAccountId;
  String? _toAccountId;

  bool _isTransferring = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ============================================================
  // TRANSFER MONEY
  // ============================================================

  Future<void> _transferMoney() async {
    // ----------------------------------------------------------
    // VALIDATE FORM
    // ----------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ----------------------------------------------------------
    // CHECK ACCOUNT SELECTION
    // ----------------------------------------------------------

    if (_fromAccountId == null ||
        _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select both accounts',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // SAME ACCOUNT CHECK
    // ----------------------------------------------------------

    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'From and To accounts must be different',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // GET AMOUNT
    // ----------------------------------------------------------

    final double? amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid amount',
          ),
        ),
      );

      return;
    }

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
    // GET ACCOUNT PROVIDER
    // ----------------------------------------------------------

    final AccountProvider provider =
        Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    // ----------------------------------------------------------
    // START LOADING
    // ----------------------------------------------------------

    setState(() {
      _isTransferring = true;
    });

    try {
      // --------------------------------------------------------
      // TRANSFER THROUGH BACKEND
      // --------------------------------------------------------

      final bool success =
          await provider.transferMoney(
        token: token,
        fromAccountId: _fromAccountId!,
        toAccountId: _toAccountId!,
        amount: amount,
      );

      // --------------------------------------------------------
      // CHECK WIDGET
      // --------------------------------------------------------

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // STOP LOADING
      // --------------------------------------------------------

      setState(() {
        _isTransferring = false;
      });

      // --------------------------------------------------------
      // TRANSFER FAILED
      // --------------------------------------------------------

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ??
                  'Insufficient balance or transfer failed.',
            ),
          ),
        );

        return;
      }

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Money transferred successfully',
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // --------------------------------------------------------
      // CLEAR AMOUNT
      // --------------------------------------------------------

      _amountController.clear();

      // --------------------------------------------------------
      // GO BACK
      // --------------------------------------------------------

      Navigator.pop(context);
    } catch (e) {
      // --------------------------------------------------------
      // STOP LOADING
      // --------------------------------------------------------

      if (!mounted) {
        return;
      }

      setState(() {
        _isTransferring = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transfer failed: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transfer Money',
        ),
        centerTitle: true,
      ),

      body: Consumer<AccountProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          final accounts = provider.accounts;

          // ======================================================
          // NEED TWO ACCOUNTS
          // ======================================================

          if (accounts.length < 2) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Add at least two accounts to transfer money.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          // ======================================================
          // DEFAULT FROM ACCOUNT
          // ======================================================

          if (_fromAccountId == null ||
              !accounts.any(
                (account) =>
                    account.id == _fromAccountId,
              )) {
            _fromAccountId = accounts.first.id;
          }

          // ======================================================
          // DEFAULT TO ACCOUNT
          // ======================================================

          if (_toAccountId == null ||
              !accounts.any(
                (account) =>
                    account.id == _toAccountId,
              ) ||
              _toAccountId == _fromAccountId) {
            _toAccountId = accounts.firstWhere(
              (account) =>
                  account.id != _fromAccountId,
            ).id;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // INFORMATION CARD
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFEFF6FF,
                      ),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),

                    child: const Row(
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          color: Color(
                            0xFF2563EB,
                          ),
                        ),

                        SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'Transfer money from one PayEase account to another.',
                            style: TextStyle(
                              color: Color(
                                0xFF1E40AF,
                              ),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // FROM ACCOUNT
                  // ==================================================

                  DropdownButtonFormField<String>(
                    initialValue:
                        _fromAccountId,

                    decoration:
                        const InputDecoration(
                      labelText: 'From Account',
                      prefixIcon:
                          Icon(Icons.upload),
                      border:
                          OutlineInputBorder(),
                    ),

                    items: accounts.map(
                      (account) {
                        return DropdownMenuItem<
                            String>(
                          value: account.id,

                          child: Text(
                            '${account.name} • ₹${account.balance.toStringAsFixed(2)}',
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ).toList(),

                    onChanged:
                        _isTransferring
                            ? null
                            : (value) {
                                if (value ==
                                    null) {
                                  return;
                                }

                                setState(() {
                                  _fromAccountId =
                                      value;

                                  // Automatically change
                                  // destination if same.
                                  if (_toAccountId ==
                                      value) {
                                    for (final account
                                        in accounts) {
                                      if (account.id !=
                                          value) {
                                        _toAccountId =
                                            account.id;
                                        break;
                                      }
                                    }
                                  }
                                });
                              },
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // SWAP ICON
                  // ==================================================

                  Center(
                    child: Container(
                      height: 45,
                      width: 45,

                      decoration:
                          const BoxDecoration(
                        color: Color(
                          0xFFEFF6FF,
                        ),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.swap_vert,
                        color: Color(
                          0xFF2563EB,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // TO ACCOUNT
                  // ==================================================

                  DropdownButtonFormField<String>(
                    initialValue:
                        _toAccountId,

                    decoration:
                        const InputDecoration(
                      labelText: 'To Account',
                      prefixIcon:
                          Icon(Icons.download),
                      border:
                          OutlineInputBorder(),
                    ),

                    items: accounts.map(
                      (account) {
                        return DropdownMenuItem<
                            String>(
                          value: account.id,

                          child: Text(
                            '${account.name} • ₹${account.balance.toStringAsFixed(2)}',
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ).toList(),

                    onChanged:
                        _isTransferring
                            ? null
                            : (value) {
                                if (value ==
                                    null) {
                                  return;
                                }

                                setState(() {
                                  _toAccountId =
                                      value;
                                });
                              },
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // AMOUNT
                  // ==================================================

                  TextFormField(
                    controller:
                        _amountController,

                    enabled:
                        !_isTransferring,

                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Transfer Amount',
                      hintText:
                          'Enter amount',
                      prefixIcon: Icon(
                        Icons.currency_rupee,
                      ),
                      border:
                          OutlineInputBorder(),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter amount';
                      }

                      final double? amount =
                          double.tryParse(
                        value.trim(),
                      );

                      if (amount == null ||
                          amount <= 0) {
                        return 'Enter a valid amount';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // TRANSFER BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _isTransferring
                              ? null
                              : _transferMoney,

                      icon:
                          _isTransferring
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                ),

                      label: Text(
                        _isTransferring
                            ? 'Transferring...'
                            : 'Transfer Money',

                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}