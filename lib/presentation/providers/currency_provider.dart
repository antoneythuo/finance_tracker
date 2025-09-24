import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/exchange_rate_model.dart';
import '../../domain/usecases/fetch_exchange_rates_usecase.dart';

class CurrencyProvider extends ChangeNotifier {
  final FetchExchangeRatesUseCase? fetchExchangeRatesUseCase;

  List<ExchangeRateModel> _exchangeRates = [];
  bool _isLoadingRates = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  Timer? _refreshTimer;

  List<ExchangeRateModel> get exchangeRates => _exchangeRates;
  bool get isLoadingRates => _isLoadingRates;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;

  CurrencyProvider({this.fetchExchangeRatesUseCase}) {
    _startRefreshTimer();
  }

  Future<void> fetchExchangeRates() async {
    _isLoadingRates = true;
    notifyListeners();
    
    try {
      // Simulate API call with mock data
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock API response - in a real app, replace with actual API call:
      // final response = await http.get(Uri.parse('https://njuguna.free.beeceptor.com/exchangeRtes'));
      // final data = jsonDecode(response.body) as Map<String, dynamic>;
      // final pairs = data['pairs'] as List;
      
      // Mock data matching the expected format
      final pairsList = [
        {'pair': 'KES/USD', 'rate': 0.0075},
        {'pair': 'KES/GBP', 'rate': 0.0054},
        {'pair': 'KES/EUR', 'rate': 0.0060},
        {'pair': 'KES/CNY', 'rate': 0.051},
        {'pair': 'KES/UGX', 'rate': 0.029},
        {'pair': 'KES/TZS', 'rate': 0.058},
        {'pair': 'KES/RWF', 'rate': 0.126},
        {'pair': 'KES/ZAR', 'rate': 0.074},
      ];
      
      _exchangeRates = ExchangeRateModel.fromApiList(pairsList);
      _lastUpdated = DateTime.now();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load exchange rates. Using default rates.';
      debugPrint('Error fetching exchange rates: $e');
      
      // Fallback to default rates if API fails
      final fallbackPairs = [
        {'pair': 'KES/USD', 'rate': 0.0075},
        {'pair': 'KES/GBP', 'rate': 0.0054},
        {'pair': 'KES/EUR', 'rate': 0.0060},
        {'pair': 'KES/CNY', 'rate': 0.051},
      ];
      _exchangeRates = ExchangeRateModel.fromApiList(fallbackPairs);
    } finally {
      _isLoadingRates = false;
      notifyListeners();
    }
  }

  double convertAmount(double amount, String from, String to) {
    if (from == to) return amount;
    final rate = getRate(to);
    if (rate == null) return amount;
    return amount * rate.buyRate;
  }

  ExchangeRateModel? getRate(String code) {
    try {
      return _exchangeRates.firstWhere((e) => e.code == code);
    } catch (_) {
      return null;
    }
  }

  bool get isRatesExpired {
    if (_lastUpdated == null) return true;
    return DateTime.now().difference(_lastUpdated!).inHours >= 1;
  }

  Future<void> refreshRates() async {
    await fetchExchangeRates();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(hours: 1), (_) async {
      await refreshRates();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
