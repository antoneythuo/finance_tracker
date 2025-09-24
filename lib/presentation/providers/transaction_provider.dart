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

  // Add mock data for when API is unavailable
  void _useMockData() {
    _transactions = [
      TransactionModel(
        id: '1',
        date: DateTime.now().subtract(const Duration(days: 1)),
        baseCurrency: 'KES',
        targetCurrency: 'USD',
        rate: 0.0075,
        source: 'Equity Bank',
        status: 'Completed',
      ),
      TransactionModel(
        id: '2',
        date: DateTime.now().subtract(const Duration(days: 2)),
        baseCurrency: 'KES',
        targetCurrency: 'EUR',
        rate: 0.0062,
        source: 'Co-op Bank',
        status: 'Completed',
      ),
      TransactionModel(
        id: '3',
        date: DateTime.now().subtract(const Duration(days: 3)),
        baseCurrency: 'KES',
        targetCurrency: 'GBP',
        rate: 0.0054,
        source: 'KCB',
        status: 'Pending',
      ),
    ];
    _filteredTransactions = List.from(_transactions);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      _transactions.insert(0, transaction);
      _filteredTransactions = List.from(_transactions);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final idx = _transactions.indexWhere((t) => t.id == transaction.id);
      if (idx != -1) {
        _transactions[idx] = transaction;
        _filteredTransactions = List.from(_transactions);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      _transactions.removeWhere((t) => t.id == id);
      _filteredTransactions = List.from(_transactions);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
