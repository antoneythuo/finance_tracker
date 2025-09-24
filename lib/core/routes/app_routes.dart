import 'package:flutter/material.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/add_transaction_page.dart';
import '../../presentation/pages/exchange_rates_page.dart';
import '../../presentation/pages/transaction_list_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String addTransaction = '/add-transaction';
  static const String exchangeRates = '/exchange-rates';
  static const String transactionList = '/transaction-list';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case home:
        page = const HomePage();
        break;
      case addTransaction:
        page = const AddTransactionPage();
        break;
      case exchangeRates:
        page = const ExchangeRatesPage();
        break;
      case transactionList:
        page = const TransactionListPage();
        break;
      default:
        page = Scaffold(
          body: Center(child: Text('No route defined for \'${settings.name}\'')),
        );
    }
    // Custom slide transition for main pages
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Use slide for main, fade for dialogs
        if (settings.name == addTransaction || settings.name == exchangeRates || settings.name == transactionList || settings.name == home) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        } else {
          return FadeTransition(opacity: animation, child: child);
        }
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  static void navigateToAddTransaction(BuildContext context) {
    Navigator.of(context).pushNamed(addTransaction);
  }

  static void navigateToExchangeRates(BuildContext context) {
    Navigator.of(context).pushNamed(exchangeRates);
  }

  static void navigateToTransactionList(BuildContext context) {
    Navigator.of(context).pushNamed(transactionList);
  }

  static void navigateBack(BuildContext context) {
    Navigator.of(context).maybePop();
  }
}
