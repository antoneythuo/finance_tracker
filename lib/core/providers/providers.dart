import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/transaction_provider.dart';
import '../../presentation/providers/currency_provider.dart';
import '../../presentation/providers/app_provider.dart';

Widget buildAppProviders({required Widget child}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => TransactionProvider()),
      ChangeNotifierProvider(create: (context) => CurrencyProvider()),
      ChangeNotifierProvider(
        create: (context) => AppProvider(),
      ),
    ],
    child: child,
  );
}
