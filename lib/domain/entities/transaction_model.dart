class TransactionModel {
  final String id;
  final DateTime date;
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final String source;
  final String status;

  TransactionModel({
    required this.id,
    required this.date,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.source,
    required this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      baseCurrency: json['baseCurrency'] as String,
      targetCurrency: json['targetCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      source: json['source'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'baseCurrency': baseCurrency,
        'targetCurrency': targetCurrency,
        'rate': rate,
        'source': source,
        'status': status,
      };
}
