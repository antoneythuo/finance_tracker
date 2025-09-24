class ExchangeRateModel {
  final String code;
  final String name;
  final String flag;
  final double buyRate;
  final double sellRate;

  ExchangeRateModel({
    required this.code,
    required this.name,
    required this.flag,
    required this.buyRate,
    required this.sellRate,
  });

  // Factory for API mapping
  factory ExchangeRateModel.fromApi(String code, String name, String flag, double rate) {
    // API gives KES/XXX, we want XXX/KES
    double base = 1.0 / rate;
    double buy = base * 0.995; // 0.5% below mid for buy
    double sell = base * 1.005; // 0.5% above mid for sell
    return ExchangeRateModel(
      code: code,
      name: name,
      flag: flag,
      buyRate: double.parse(buy.toStringAsFixed(2)),
      sellRate: double.parse(sell.toStringAsFixed(2)),
    );
  }

  // Map API pairs to models
  static List<ExchangeRateModel> fromApiList(List apiPairs) {
    const currencyMeta = {
      'USD': {'name': 'United States Dollar', 'flag': '🇺🇸'},
      'GBP': {'name': 'Great British Pound', 'flag': '🇬🇧'},
      'EUR': {'name': 'Euro', 'flag': '🇪🇺'},
      'CNY': {'name': 'China Yuan', 'flag': '🇨🇳'},
      'UGX': {'name': 'Uganda Shilling', 'flag': '🇺🇬'},
      'TZS': {'name': 'Tanzania Shilling', 'flag': '🇹🇿'},
      'RWF': {'name': 'Rwanda Franc', 'flag': '🇷🇼'},
      'ZAR': {'name': 'South Africa Rand', 'flag': '🇿🇦'},
    };
    return apiPairs.map<ExchangeRateModel>((pair) {
      final parts = (pair['pair'] as String).split('/');
      final code = parts[1];
      final meta = currencyMeta[code] ?? {'name': code, 'flag': ''};
      return ExchangeRateModel.fromApi(
        code,
        meta['name']!,
        meta['flag']!,
        (pair['rate'] as num).toDouble(),
      );
    }).toList();
  }
}
