import 'dart:typed_data';

import 'package:finance_tracker/core/utils/date_utils.dart';
import 'package:finance_tracker/domain/entities/transaction_representable.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFService {
	PDFService({pw.Font? customFont}) : _font = customFont;
	final pw.Font? _font;

	Future<Uint8List> generateTransactionReceipt(Transaction transaction) async {
		try {
			final doc = pw.Document();
			final theme = pw.ThemeData.withFont(base: _font);
			doc.addPage(
				pw.Page(
					theme: theme,
					build: (context) {
						return pw.Column(
							crossAxisAlignment: pw.CrossAxisAlignment.start,
							children: [
								pw.Text('Finance Tracker', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
								pw.SizedBox(height: 6),
								pw.Text('Transaction Receipt', style: pw.TextStyle(fontSize: 16)),
								pw.Divider(),
								pw.Text('ID: ${transaction.id}'),
								pw.Text('Amount: ${NumberFormat.simpleCurrency(name: transaction.currency).format(transaction.amount)}'),
								pw.Text('Date: ${CoreDateUtils.formatDateTime(transaction.date)}'),
								if (transaction.description != null) pw.Text('Description: ${transaction.description}'),
								if (transaction.category != null) pw.Text('Category: ${transaction.category}'),
								pw.Text('Type: ${transaction.type.name}')
							],
						);
					},
				),
			);
			return doc.save();
		} catch (e) {
			throw Exception('Failed to generate receipt: $e');
		}
	}

	Future<Uint8List> generateMonthlyReport(List<Transaction> transactions, DateTime month) async {
		try {
			final doc = pw.Document();
			final theme = pw.ThemeData.withFont(base: _font);

			final monthLabel = DateFormat('MMMM yyyy').format(DateTime(month.year, month.month));
			final monthTx = transactions.where((t) => t.date.year == month.year && t.date.month == month.month).toList();
			final totalIncome = monthTx.where((t) => (t as dynamic).type.name == 'income').fold<double>(0, (sum, t) => sum + t.amount);
			final totalExpense = monthTx.where((t) => (t as dynamic).type.name == 'expense').fold<double>(0, (sum, t) => sum + t.amount);
			final net = totalIncome - totalExpense;

			doc.addPage(
				pw.MultiPage(
					theme: theme,
					build: (context) => [
						pw.Header(level: 0, child: pw.Text('Finance Tracker - $monthLabel')),
						pw.Paragraph(text: 'Monthly Summary'),
						pw.Bullet(text: 'Total income: ${NumberFormat.simpleCurrency(name: monthTx.isEmpty ? 'USD' : monthTx.first.currency).format(totalIncome)}'),
						pw.Bullet(text: 'Total expense: ${NumberFormat.simpleCurrency(name: monthTx.isEmpty ? 'USD' : monthTx.first.currency).format(totalExpense)}'),
						pw.Bullet(text: 'Net: ${NumberFormat.simpleCurrency(name: monthTx.isEmpty ? 'USD' : monthTx.first.currency).format(net)}'),
						pw.SizedBox(height: 16),
						pw.Text('Transactions', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
						// ignore: deprecated_member_use
						pw.Table.fromTextArray(
							headers: ['Date', 'Description', 'Category', 'Type', 'Amount'],
							data: [
								for (final t in monthTx)
									[CoreDateUtils.formatDate(t.date), t.description ?? '-', t.category ?? '-', (t as dynamic).type.name, NumberFormat.simpleCurrency(name: t.currency).format(t.amount)],
							],
						),
					],
				),
			);
			return doc.save();
		} catch (e) {
			throw Exception('Failed to generate monthly report: $e');
		}
	}

	Future<void> saveToDevice(Uint8List bytes, Future<String> Function() pathProvider) async {
		try {
			final path = await pathProvider();
			if (path.isEmpty) throw Exception('Invalid path');
		} catch (e) {
			throw Exception('Failed to save PDF: $e');
		}
	}

	Future<void> shareReceipt(Uint8List bytes) async {}
} 