import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final String _apiUrl = 'https://njuguna.free.beeceptor.com/transactions';
  
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<TransactionModel> _filteredTransactions = [];

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TransactionModel> get filteredTransactions => _filteredTransactions;

  TransactionProvider() {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _transactions = data.map((json) => TransactionModel.fromJson(json)).toList();
        _filteredTransactions = List.from(_transactions);
      } else {
        _errorMessage = 'Failed to load transactions. Status code: ${response.statusCode}';
        // Use mock data if API fails
        _useMockData();
      }
    } catch (e) {
      _errorMessage = 'Error loading transactions: $e';
      // Use mock data if there's an error
      _useMockData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _useMockData() {
    _transactions = [
      TransactionModel(
        id: 'EXR1001',
        date: DateTime.parse('2025-07-01'),
        baseCurrency: 'KES',
        targetCurrency: 'CNY',
        rate: 0.053,
        source: 'Co-op Bank',
        status: 'Success',
      ),
      TransactionModel(
        id: 'EXR1002',
        date: DateTime.parse('2025-07-01'),
        baseCurrency: 'KES',
        targetCurrency: 'USD',
        rate: 0.0075,
        source: 'Equity Bank',
        status: 'Success',
      ),
    ];
    _filteredTransactions = List.from(_transactions);
  }

  // Add methods for filtering, searching, etc. as needed
  void filterTransactions(String query) {
    if (query.isEmpty) {
      _filteredTransactions = List.from(_transactions);
    } else {
      _filteredTransactions = _transactions.where((transaction) {
        return transaction.id.toLowerCase().contains(query.toLowerCase()) ||
               transaction.baseCurrency.toLowerCase().contains(query.toLowerCase()) ||
               transaction.targetCurrency.toLowerCase().contains(query.toLowerCase()) ||
               transaction.source.toLowerCase().contains(query.toLowerCase()) ||
               transaction.status.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}
