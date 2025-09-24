import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/transaction_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({Key? key}) : super(key: key);
  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  // For demo, pagination is not implemented. Add logic if backend supports it.
  @override
  void initState() {
    super.initState();
    Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(),
          ),
          Expanded(
            child: provider.isLoading
                ? LoadingWidget(state: LoadingState.transactionList)
                : provider.errorMessage != null
                    ? CustomErrorWidget(
                        message: provider.errorMessage!,
                        type: ErrorType.network,
                        onRetry: () => provider.loadTransactions(),
                      )
                    : provider.filteredTransactions.isEmpty
                        ? LoadingWidget(state: LoadingState.empty)
                        : ListView.builder(
                            itemCount: provider.filteredTransactions.length,
                            itemBuilder: (context, i) => TransactionCard(transaction: provider.filteredTransactions[i]),
                          ),
          ),
        ],
      ),
    );
  }
}
