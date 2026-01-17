import 'package:event_planning_app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:uuid/uuid.dart';

class PaymentScreen extends StatefulWidget {
  final String amount;
  final String email;
  final String currency;

  const PaymentScreen(
      {super.key,
      required this.amount,
      required this.email,
      this.currency = "NGN"});

  @override
  State<PaymentScreen> createState() => _PaymentScreen();
}

class _PaymentScreen extends State<PaymentScreen> {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final currencyController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();

  String selectedCurrency = "NGN";
  bool isLoading = false;
  bool isTestMode = true;

  @override
  void initState() {
    super.initState();
    amountController.text = widget.amount;
    emailController.text = widget.email;
    selectedCurrency = widget.currency;
    currencyController.text = selectedCurrency;
  }

  @override
  Widget build(BuildContext context) {
    currencyController.text = selectedCurrency;

    return Scaffold(
      appBar: AppBar(title: const Text('Flutterwave')),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Form(
          key: formKey,
          child: ListView(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: TextFormField(
                  controller: amountController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(hintText: "Amount"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount is required';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: TextFormField(
                  controller: currencyController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  readOnly: true,
                  onTap: _openBottomSheet,
                  decoration: const InputDecoration(hintText: "Currency"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Currency is required';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: TextFormField(
                  controller: emailController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(hintText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: Row(
                  children: [
                    const Text("Use Debug", style: TextStyle(color: kLavender)),
                    Switch(
                      onChanged: (value) => {
                        setState(() {
                          isTestMode = value;
                        }),
                      },
                      value: isTestMode,
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(kLavender),
                  ),
                  onPressed: isLoading ? null : makePayment,
                  child: const Text(
                    "Make Payment",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void makePayment() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Customer customer = Customer(
        email: emailController.text,
      );

      final Flutterwave flutterwave = Flutterwave(
        publicKey: "FLWPUBK_TEST-85c194712bfb20b8b3da5e4c8a76250a-X",
        currency: selectedCurrency,
        amount: amountController.text.toString().trim(),
        customer: customer,
        txRef: const Uuid().v4(),
        paymentOptions: "card, ussd, bank transfer",
        customization: Customization(
          title: "Payment for Event Ticket",
          description: "Payment for ticket",
        ),
        redirectUrl: "https://www.flutterwave.com",
        isTestMode: isTestMode,
      );

      final ChargeResponse response = await flutterwave.charge(
        context,
      );

      if (mounted) {
        if (response.success == true) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Payment Successful',
                    style: TextStyle(color: Colors.white)),
                content: Text(
                  'Transaction Reference: ${response.txRef}',
                  style: const TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        Navigator.of(context).pop('payment_success');
                      });
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Payment Failed',
                    style: TextStyle(color: Colors.white)),
                content: Text('Status: ${response.status}',
                    style: const TextStyle(color: Colors.white)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(e.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _getCurrency();
      },
    );
  }

  Widget _getCurrency() {
    final currencies = [
      "NGN",
      "RWF",
      "UGX",
      "KES",
      "ZAR",
      "USD",
      "GHS",
      "TZS",
    ];
    return Container(
      height: 250,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      color: Colors.white,
      child: ListView(
        children: currencies
            .map(
              (currency) => ListTile(
                onTap: () => {_handleCurrencyTap(currency)},
                title: Column(
                  children: [
                    Text(
                      currency,
                      textAlign: TextAlign.start,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    const Divider(height: 1),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  _handleCurrencyTap(String currency) {
    setState(() {
      selectedCurrency = currency;
      currencyController.text = currency;
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    amountController.dispose();
    currencyController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }
}
