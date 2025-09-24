import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../../domain/entities/transaction_model.dart';
import '../widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({Key? key}) : super(key: key);
  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _baseCurrencyController = TextEditingController(text: 'KES');
  final TextEditingController _targetCurrencyController = TextEditingController(text: 'USD');
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final _targetCurrencies = ['USD', 'EUR', 'GBP', 'ZAR', 'UGX', 'TZS'];
  String _status = 'Pending';
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _baseCurrencyController.dispose();
    _targetCurrencyController.dispose();
    _rateController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      baseCurrency: _baseCurrencyController.text.trim(),
      targetCurrency: _targetCurrencyController.text.trim(),
      rate: rate,
      source: _sourceController.text.trim(),
      status: _status,
    );
    
    await provider.addTransaction(transaction);
    setState(() => _isLoading = false);
    
    if (provider.errorMessage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully!'),
            backgroundColor: Color(0xFF2ECC71),
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Add Currency Exchange',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const LoadingWidget(state: LoadingState.general)
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Currency Exchange Form
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _baseCurrencyController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'From',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _targetCurrencyController.text,
                              decoration: InputDecoration(
                                labelText: 'To',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              items: _targetCurrencies.map<DropdownMenuItem<String>>((currency) {
                                return DropdownMenuItem<String>(
                                  value: currency,
                                  child: Text(currency),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => _targetCurrencyController.text = v ?? 'USD'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Exchange Rate
                      TextFormField(
                        controller: _rateController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Exchange Rate (1 ${_baseCurrencyController.text} to ${_targetCurrencyController.text})',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter exchange rate';
                          final rate = double.tryParse(v);
                          if (rate == null || rate <= 0) return 'Enter a valid rate';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Date picker
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF2ECC71)),
                            ),
                            controller: TextEditingController(
                              text: DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Source
                      TextFormField(
                        controller: _sourceController,
                        decoration: InputDecoration(
                          labelText: 'Source (e.g., Bank, M-Pesa)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Enter source' : null,
                      ),
                      const SizedBox(height: 24),
                      // Status Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text('Pending'),
                            selected: _status == 'Pending',
                            selectedColor: Colors.orange,
                            backgroundColor: Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color: _status == 'Pending' ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (v) => setState(() => _status = 'Pending'),
                          ),
                          const SizedBox(width: 16),
                          ChoiceChip(
                            label: const Text('Completed'),
                            selected: _status == 'Completed',
                            selectedColor: const Color(0xFF2ECC71),
                            backgroundColor: Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color: _status == 'Completed' ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (v) => setState(() => _status = 'Completed'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      // Add button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Add Exchange',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
