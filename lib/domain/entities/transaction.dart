class Transaction {
  final String id;
  final double amount;
  final String currency;
  final DateTime date;
  final String category;
  final String description;

  Transaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.date,
    required this.category,
    required this.description,
  });
}
