import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction_model.dart';

class PdfExportService {
  /// Generate and share/print a PDF of all transactions
  static Future<void> exportTransactions({
    required List<TransactionModel> transactions,
    required double totalBalance,
    required double totalIncome,
    required double totalExpenses,
    required String userName,
  }) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr =
        '${now.day}/${now.month}/${now.year}  ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => _buildHeader(userName, dateStr),
        footer: (ctx) => _buildFooter(ctx),
        build: (ctx) => [
          _buildSummarySection(totalBalance, totalIncome, totalExpenses),
          pw.SizedBox(height: 24),
          _buildTransactionsTable(transactions),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename:
          'cashflow_transactions_${now.day}-${now.month}-${now.year}.pdf',
    );
  }

  static pw.Widget _buildHeader(String userName, String dateStr) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('CASHFLOW DASHBOARD',
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey800)),
                pw.Text('Transaction Report',
                    style: pw.TextStyle(
                        fontSize: 11, color: PdfColors.grey600)),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(userName,
                    style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey700)),
                pw.Text('Generated: $dateStr',
                    style: pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey500)),
              ],
            ),
          ],
        ),
        pw.Divider(color: PdfColors.blueGrey200, thickness: 1.5),
        pw.SizedBox(height: 4),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context ctx) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Cashflow Dashboard — Confidential',
                style: pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey400)),
            pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                style: pw.TextStyle(
                    fontSize: 8, color: PdfColors.grey400)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummarySection(
      double balance, double income, double expenses) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryTile('Total Balance',
              'PKR ${balance.toStringAsFixed(2)}', PdfColors.blueGrey800),
          _summaryTile('Total Income',
              'PKR ${income.toStringAsFixed(2)}', PdfColors.green700),
          _summaryTile('Total Expenses',
              'PKR ${expenses.toStringAsFixed(2)}', PdfColors.red700),
        ],
      ),
    );
  }

  static pw.Widget _summaryTile(
      String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: color)),
      ],
    );
  }

  static pw.Widget _buildTransactionsTable(
      List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return pw.Center(
        child: pw.Text('No transactions found.',
            style: pw.TextStyle(color: PdfColors.grey500)),
      );
    }

    return pw.TableHelper.fromTextArray(
      headers: ['#', 'Date', 'Title', 'Note', 'Type', 'Amount'],
      headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
          color: PdfColors.white),
      headerDecoration:
          const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellStyle: const pw.TextStyle(fontSize: 9),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
      oddRowDecoration:
          const pw.BoxDecoration(color: PdfColors.blueGrey50),
      cellAlignments: {
        0: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
      },
      data: List.generate(transactions.length, (i) {
        final t = transactions[i];
        final isIncome = t.type == TransactionType.income;
        return [
          '${i + 1}',
          '${t.createdAt.day}/${t.createdAt.month}/${t.createdAt.year}',
          t.title,
          t.subtitle,
          isIncome ? 'Income' : 'Expense',
          t.formattedAmount,
        ];
      }),
    );
  }
}
