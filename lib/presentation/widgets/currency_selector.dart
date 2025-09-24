import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/currency_provider.dart';

class CurrencySelectorWidget extends StatelessWidget {
  final String selectedCurrency;
  final ValueChanged<String> onChanged;
  final List<String> supportedCurrencies;

  const CurrencySelectorWidget({
    Key? key,
    required this.selectedCurrency,
    required this.onChanged,
    required this.supportedCurrencies,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      icon: const Icon(Icons.arrow_drop_down),
      decoration: InputDecoration(
        labelText: 'Currency',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: supportedCurrencies.map((code) {
        return DropdownMenuItem<String>(
          value: code,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  code.substring(0, 2),
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),
              const SizedBox(width: 8),
              Text(code),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          try {
            onChanged(value);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error selecting currency: $e')),
            );
          }
        }
      },
    );
  }
}
