import 'package:flutter/material.dart';
import '../../../models/client_model.dart';
import '../../../models/client_sale_model.dart';
import '../../../res/app_colors.dart';
import '../../../view_models/client_controller.dart';
import 'add_sale_sheet.dart';
import 'record_payment_sheet.dart';

class ClientBalanceCard extends StatelessWidget {
  final ClientModel client;
  final ClientController ctrl;

  const ClientBalanceCard(
      {super.key, required this.client, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (!client.hasBalance) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.2)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Colors.green, size: 20),
            SizedBox(width: 10),
            Text('No outstanding balance',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    final creditSales = ctrl
        .salesFor(client.id)
        .where((s) =>
            s.status == SalePaymentStatus.credit ||
            s.status == SalePaymentStatus.partial)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Text('Outstanding Balance',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlue,
                          fontSize: 10)),
                ],
              ),
              Text(
                'Rs ${client.outstandingBalance.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
            ],
          ),
          if (creditSales.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.dividerGray),
            const SizedBox(height: 10),
            ...creditSales.map((s) => _CreditSaleRow(
                  sale: s,
                  onPayment: () => _showPaymentSheet(context, s),
                )),
          ],
        ],
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, ClientSaleModel sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => RecordPaymentSheet(
        sale: sale,
        ctrl: ctrl,
      ),
    );
  }
}

class _CreditSaleRow extends StatelessWidget {
  final ClientSaleModel sale;
  final VoidCallback onPayment;

  const _CreditSaleRow({required this.sale, required this.onPayment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sale.itemDescription,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlue)),
                Text(
                  'Rs ${sale.paidAmount.toStringAsFixed(0)} / Rs ${sale.totalAmount.toStringAsFixed(0)} paid',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.grayText),
                ),
                if (sale.dueDate != null)
                  Text(
                    'Due: ${sale.dueDate!.day}/${sale.dueDate!.month}/${sale.dueDate!.year}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.redAccent),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onPayment,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryBlue.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('Pay',
                style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
