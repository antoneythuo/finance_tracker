import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionCard({Key? key, required this.transaction, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPending = transaction.status == 'Pending';
    final amountColor = isPending ? const Color(0xFFFFA500) : const Color(0xFF2ECC71);
    final icon = isPending ? Icons.pending : Icons.check_circle;
    final formattedDate = DateFormat('MMM d, y').format(transaction.date);
    final formattedTime = DateFormat('h:mm a').format(transaction.date);
    final amount = 1000 * transaction.rate; // Assuming 1000 units of base currency
    final formattedAmount = '${transaction.baseCurrency} ${amount.toStringAsFixed(2)} → ${transaction.targetCurrency} ${(amount * transaction.rate).toStringAsFixed(2)}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                  child: Icon(Icons.category, color: Theme.of(context).primaryColor),
                  radius: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${transaction.baseCurrency} → ${transaction.targetCurrency} Exchange',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rate: ${transaction.rate.toStringAsFixed(6)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Source: ${transaction.source}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(DateFormat.yMMMd().format(transaction.date), style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            transaction.status,
                            style: TextStyle(
                              color: isPending ? Colors.orange[800] : Colors.green[800],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formattedAmount,
                      style: TextStyle(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPending ? Colors.orange[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        transaction.status,
                        style: TextStyle(
                          color: isPending ? Colors.orange[800] : Colors.green[800],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
