import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction_model.dart';
import '../models/client_model.dart';
import '../models/client_sale_model.dart';

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
      ];
      }),
    );
  }

  /// Generate and share/print a PDF of selected purchase invoices
  static Future<void> exportPurchaseInvoices({
    required List<ClientSaleModel> sales,
    required ClientModel client,
    required String userName,
    bool printDirectly = false,
  }) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final pdf = pw.Document();
    final now = DateTime.now();

    final isMultiple = sales.length > 1;
    final title = isMultiple ? 'PURCHASE STATEMENT' : 'INVOICE';
    final refStr = isMultiple 
        ? 'MULTIPLE RECORDS' 
        : 'INV-${sales.first.id.substring(0, 6).toUpperCase()}';

    double totalSubtotal = 0;
    double totalDiscount = 0;
    double totalGrand = 0;
    double totalPaid = 0;
    double totalRemaining = 0;

    for (final s in sales) {
      double sub = s.hasInventoryData ? (s.unitPrice ?? 0) * (s.quantity ?? 1) : s.totalAmount;
      double finalAmt = s.finalAmount ?? s.totalAmount;
      
      totalSubtotal += sub;
      totalDiscount += (sub - finalAmt);
      totalGrand += finalAmt;
      totalPaid += s.paidAmount;
      totalRemaining += s.pendingAmount;
    }

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                    pw.SizedBox(height: 4),
                    pw.Text(refStr, style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(userName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('Date: ${now.day}/${now.month}/${now.year}', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            _buildInvoiceClientInfo(client),
            pw.SizedBox(height: 32),
            _buildCombinedItemsTable(sales),
            pw.SizedBox(height: 16),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 250,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _summaryRow('Subtotal:', 'Rs ${totalSubtotal.toStringAsFixed(0)}'),
                    if (totalDiscount > 0)
                      _summaryRow('Total Discount:', 'Rs ${totalDiscount.toStringAsFixed(0)}'),
                    pw.Divider(color: PdfColors.grey400),
                    _summaryRow('Grand Total:', 'Rs ${totalGrand.toStringAsFixed(0)}', isBold: true),
                    pw.SizedBox(height: 8),
                    _summaryRow('Paid Amount:', 'Rs ${totalPaid.toStringAsFixed(0)}', color: PdfColors.green700),
                    _summaryRow('Remaining:', 'Rs ${totalRemaining.toStringAsFixed(0)}', color: PdfColors.red700),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );

    if (printDirectly) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'invoices_${client.name.replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}',
      );
    } else {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'invoices_${client.name.replaceAll(' ', '_')}_${now.millisecondsSinceEpoch}.pdf',
      );
    }
  }

  static pw.Widget _buildInvoiceClientInfo(ClientModel client) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(6)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Billed To:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(client.name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
          pw.SizedBox(height: 2),
          pw.Text(client.phone, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
          if (client.email.isNotEmpty) pw.Text(client.email, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
          if (client.address.isNotEmpty) pw.Text(client.address, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
        ],
      ),
    );
  }

  static pw.Widget _buildCombinedItemsTable(List<ClientSaleModel> sales) {
    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Item Description', 'Status', 'Qty', 'Unit Price', 'Total'],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
      data: sales.map((sale) {
        final dateStr = '${sale.date.day}/${sale.date.month}/${sale.date.year}';
        final desc = sale.hasInventoryData ? (sale.productName ?? '') : sale.itemDescription;
        final qty = sale.hasInventoryData ? '${sale.quantity}' : '-';
        final price = sale.hasInventoryData ? 'Rs ${sale.unitPrice?.toStringAsFixed(0)}' : '-';
        final total = sale.hasInventoryData 
          ? 'Rs ${((sale.unitPrice ?? 0) * (sale.quantity ?? 1)).toStringAsFixed(0)}'
          : 'Rs ${sale.totalAmount.toStringAsFixed(0)}';
        
        return [dateStr, desc, sale.statusLabel, qty, price, total];
      }).toList(),
    );
  }

  static pw.Widget _summaryRow(String label, String value, {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}
