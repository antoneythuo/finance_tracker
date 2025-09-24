import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/exchange_rate_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class ExchangeRatesPage extends StatefulWidget {
  const ExchangeRatesPage({Key? key}) : super(key: key);
  @override
  State<ExchangeRatesPage> createState() => _ExchangeRatesPageState();
}

class _ExchangeRatesPageState extends State<ExchangeRatesPage> {
  final List<String> _currencies = ['USD', 'GBP', 'EUR', 'CNY', 'UGX', 'TZS', 'RWF', 'ZAR'];

  Future<void> _refresh() async {
    await Provider.of<CurrencyProvider>(context, listen: false).fetchExchangeRates();
  }

  @override
  void initState() {
    super.initState();
    // Load data when the page is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(context);
    });
  }

  Future<void> _loadData(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        );
      },
    );

    try {
      // Fetch exchange rates
      await Provider.of<CurrencyProvider>(context, listen: false).fetchExchangeRates();
      
      // Close the loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Close the loading dialog on error
      if (mounted) {
        Navigator.of(context).pop();
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load exchange rates')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurrencyProvider>(context);
    final supportedCodes = ['USD','GBP','EUR','CNY','UGX','TZS','RWF','ZAR'];
    final rates = provider.exchangeRates.where((e) => supportedCodes.contains(e.code)).toList();
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Exchange Rates'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Consumer<CurrencyProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingRates) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.25,
                ),
                itemCount: 8,
                itemBuilder: (context, i) => Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 32, width: 32, color: Colors.grey[200], margin: const EdgeInsets.only(bottom: 8)),
                        Container(height: 12, width: 50, color: Colors.grey[200], margin: const EdgeInsets.only(bottom: 4)),
                        Container(height: 10, width: 80, color: Colors.grey[100], margin: const EdgeInsets.only(bottom: 12)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(height: 10, width: 28, color: Colors.grey[200]),
                            Container(height: 10, width: 28, color: Colors.grey[200]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            if (provider.errorMessage != null) {
              return CustomErrorWidget(
                message: provider.errorMessage!,
                type: ErrorType.network,
                onRetry: _refresh,
              );
            }
            if (rates.isEmpty) {
              return LoadingWidget(state: LoadingState.empty);
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.25,
              ),
              itemCount: rates.length,
              itemBuilder: (context, i) => ExchangeRateCard(rate: rates[i]),
            );
          },
        ),
      ),
    );
  }
}
