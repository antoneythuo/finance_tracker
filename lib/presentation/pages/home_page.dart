import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';

import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'add_transaction_page.dart';
import 'transaction_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
      Provider.of<CurrencyProvider>(context, listen: false).fetchExchangeRates();
    });
  }

  void _onNavTap(int idx) {
    setState(() => _selectedIndex = idx);
    if (idx == 1) {
      // Exchange Rate tab navigation
      Navigator.of(context).pushNamed('/exchange-rates');
    } else if (idx == 2) {
      // More tab navigation (implement as needed)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer2<TransactionProvider, CurrencyProvider>(
        builder: (context, transactionProvider, currencyProvider, _) {
          final isLoading = transactionProvider.isLoading;
          final error = transactionProvider.errorMessage;
          final transactions = transactionProvider.transactions;
          // Calculate values based on exchange rates
          // Calculate total value of all transactions
          final balance = transactions.fold<double>(0, (sum, t) {
            // Assuming 1000 units of base currency for each transaction
            final amount = 1000 * t.rate;
            return sum + amount;
          });
          
          // Calculate total value of completed transactions
          final moneyIn = transactions.where((t) => t.status == 'Completed').fold<double>(0, (sum, t) {
            final amount = 1000 * t.rate;
            return sum + amount;
          });
          
          // Calculate total value of pending transactions
          final moneyOut = transactions.where((t) => t.status == 'Pending').fold<double>(0, (sum, t) {
            final amount = 1000 * t.rate;
            return sum + amount;
          });

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (error != null) {
            return Center(child: Text('Error: $error'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await transactionProvider.loadTransactions();
              await currencyProvider.fetchExchangeRates();
            },
            child: CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: false,
                  backgroundColor: const Color(0xFFF8F9FA),
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: const AssetImage('assets/avatar.jpg'),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Good Morning Tony',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Balance Card
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCurrency(balance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: Text('KES', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Money In', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'KES ${_formatCurrency(moneyIn)}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 38,
                              width: 1.1,
                              color: Colors.white24,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Money Out', style: TextStyle(color: Colors.white70, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'KES ${_formatCurrency(moneyOut)}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent Transactions
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Five Transactions',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const TransactionListPage()),
                                ),
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                    color: Color(0xFF1B5E20),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        if (isLoading)
                          const SizedBox(
                            height: 250,
                            child: LoadingWidget(state: LoadingState.transactionList),
                          ),
                        
                        if (!isLoading && error != null)
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: CustomErrorWidget(
                              message: error,
                              type: ErrorType.network,
                              onRetry: () => transactionProvider.loadTransactions(),
                            ),
                          ),
                        
                        if (!isLoading && error == null)
                          Column(
                            children: transactions.take(5).map((t) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                child: Row(
                                  children: [
                                    _buildMerchantIcon(t),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getMerchantTitle(t),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatDateTime(t.date),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${t.baseCurrency} 1 = ${t.targetCurrency} ${t.rate.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Color(0xFF1B5E20), // Dark green color
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _getCategoryLabel(t),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF2E7D32), // Slightly lighter dark green
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Add Transaction Button
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF66BB6A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddTransactionPage()),
                        ),
                        child: const Text(
                          'Add Transaction',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_vert),
              label: 'Exchange Rate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
          selectedItemColor: const Color(0xFF66BB6A),
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
        ),
      ),
    );
  }

  // --- Helper methods for balance card formatting ---
  String _formatCurrency(num value) {
    return value.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // --- Helper methods for merchant icons, titles, date, and category labels ---
  Widget _buildMerchantIcon(dynamic transaction) {
    // Map of source types to icons
    final sourceIcons = <String, IconData>{
      'bank': Icons.account_balance,
      'equity': Icons.account_balance,
      'kcb': Icons.account_balance,
      'mpesa': Icons.phone_android,
      'mobile money': Icons.phone_android,
      'paypal': Icons.payment,
      'stripe': Icons.credit_card,
      'atm': Icons.atm,
      'withdrawal': Icons.atm,
    };
    
    final source = transaction.source?.toLowerCase() ?? '';
    final iconData = sourceIcons.entries
        .firstWhere(
          (entry) => source.contains(entry.key),
          orElse: () => const MapEntry('', Icons.currency_exchange),
        )
        .value;
    
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: Colors.grey[600], size: 20),
    );
  }

  String _getMerchantTitle(dynamic transaction) {
    // Use source and status to generate a meaningful title
    final source = transaction.source?.toLowerCase() ?? '';
    final status = transaction.status?.toLowerCase() ?? '';
    
    // Map common sources to friendly names
    if (source.contains('bank') || source.contains('equity') || source.contains('kcb')) {
      return 'Bank Transfer';
    }
    if (source.contains('mpesa')) {
      return 'M-PESA';
    }
    if (source.contains('paypal')) {
      return 'PayPal';
    }
    if (source.contains('stripe')) {
      return 'Stripe Payment';
    }
    if (source.contains('atm') || source.contains('withdrawal')) {
      return 'Cash Withdrawal';
    }
    
    // If no specific source matches, use a generic title based on status
    if (status == 'pending') return 'Pending Transaction';
    if (status == 'completed') return 'Completed Transaction';
    
    // Default to source if available, otherwise a generic title
    return source.isNotEmpty 
        ? source[0].toUpperCase() + source.substring(1) // Capitalize first letter
        : 'Currency Exchange';
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return '${_monthShort(date.month)} ${date.day}, ${date.year}  ${_formatTime(date)}';
    }
  }
  
  String _monthShort(int m) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m-1];
  String _formatTime(DateTime dt) => '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';

  String _getCategoryLabel(dynamic transaction) {
    // Use source for category if available, otherwise use status
    final source = transaction.source?.toLowerCase() ?? '';
    final status = transaction.status?.toLowerCase() ?? '';
    
    // Map common sources to categories
    if (source.contains('bank') || source.contains('equity') || source.contains('kcb')) return 'Bank Transfer';
    if (source.contains('mpesa') || source.contains('mobile money')) return 'Mobile Money';
    if (source.contains('paypal') || source.contains('stripe')) return 'Online Payment';
    if (source.contains('atm') || source.contains('withdrawal')) return 'Cash Withdrawal';
    
    // If no specific source matches, use status
    if (status == 'pending') return 'Pending';
    if (status == 'completed') return 'Completed';
    
    // Default to source if available, otherwise 'Exchange'
    return transaction.source.isNotEmpty ? transaction.source : 'Exchange';
  }
}