import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/client_model.dart';
import '../../../models/client_sale_model.dart';
import '../../../res/app_colors.dart';

class PurchaseDetailsScreen extends StatelessWidget {
  final ClientSaleModel sale;
  final ClientModel client;

  const PurchaseDetailsScreen({
    super.key,
    required this.sale,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text('Purchase Details', style: TextStyle(color: Colors.white, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInvoiceHeader(),
            const SizedBox(height: 16),
            _buildClientInfo(),
            const SizedBox(height: 16),
            _buildItemsTable(),
            const SizedBox(height: 16),
            _buildSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Invoice #INV-${sale.id.substring(0, 6).toUpperCase()}', 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textBlue)),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoRow('Sale ID:', sale.id),
          _buildInfoRow('Date:', DateFormat('dd MMM yyyy, hh:mm a').format(sale.date)),
          if (sale.dueDate != null) 
            _buildInfoRow('Due Date:', DateFormat('dd MMM yyyy').format(sale.dueDate!)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    switch (sale.status) {
      case SalePaymentStatus.paid:
        color = Colors.green;
        break;
      case SalePaymentStatus.credit:
        color = Colors.redAccent;
        break;
      case SalePaymentStatus.partial:
        color = Colors.orange;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(sale.statusLabel, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildClientInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Billed To', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textBlue)),
          const SizedBox(height: 12),
          _buildInfoRow('Name:', client.name),
          _buildInfoRow('Phone:', client.phone),
          if (client.email.isNotEmpty) _buildInfoRow('Email:', client.email),
          if (client.address.isNotEmpty) _buildInfoRow('Address:', client.address),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Purchased Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textBlue)),
          const SizedBox(height: 16),
          if (sale.hasInventoryData) ...[
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  children: [
                    Text('Item', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.grayText, fontSize: 12)),
                    Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.grayText, fontSize: 12)),
                    Text('Price', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.grayText, fontSize: 12)),
                    Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.grayText, fontSize: 12)),
                  ],
                ),
                const TableRow(children: [SizedBox(height: 8), SizedBox(height: 8), SizedBox(height: 8), SizedBox(height: 8)]),
                TableRow(
                  children: [
                    Text(sale.productName ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textBlue)),
                    Text('${sale.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textBlue)),
                    Text('${sale.unitPrice?.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: AppColors.textBlue)),
                    Text('${((sale.unitPrice ?? 0) * (sale.quantity ?? 1)).toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: AppColors.textBlue)),
                  ],
                )
              ],
            ),
          ] else ...[
            // Legacy sale format
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(sale.itemDescription, style: const TextStyle(fontSize: 14, color: AppColors.textBlue))),
                Text('Rs ${sale.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textBlue)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary() {
    double subtotal = sale.hasInventoryData ? (sale.unitPrice ?? 0) * (sale.quantity ?? 1) : sale.totalAmount;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal:', 'Rs ${subtotal.toStringAsFixed(0)}'),
          if (sale.discount != null && sale.discount! > 0)
            _buildSummaryRow('Discount:', sale.discountLabel, color: Colors.green),
          const Divider(height: 24),
          _buildSummaryRow('Grand Total:', 'Rs ${(sale.finalAmount ?? sale.totalAmount).toStringAsFixed(0)}', isBold: true),
          const SizedBox(height: 8),
          _buildSummaryRow('Paid Amount:', 'Rs ${sale.paidAmount.toStringAsFixed(0)}', color: Colors.green),
          _buildSummaryRow('Remaining:', 'Rs ${sale.pendingAmount.toStringAsFixed(0)}', color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: AppColors.grayText, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.textBlue, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? AppColors.textBlue : AppColors.grayText, fontSize: isBold ? 15 : 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(color: color ?? AppColors.textBlue, fontSize: isBold ? 15 : 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}
