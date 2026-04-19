import 'package:flutter/material.dart';
import '../../../models/client_sale_model.dart';
import '../../../res/app_colors.dart';
import '../../../view_models/client_controller.dart';

class ClientSalesList extends StatelessWidget {
  final String clientId;
  final ClientController ctrl;

  const ClientSalesList(
      {super.key, required this.clientId, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final sales = ctrl.salesFor(clientId);

    if (sales.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No purchases yet.',
              style: TextStyle(color: AppColors.grayText)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sales.length,
      itemBuilder: (_, i) => _SaleTile(sale: sales[i]),
    );
  }
}

class _SaleTile extends StatelessWidget {
  final ClientSaleModel sale;
  const _SaleTile({required this.sale});

  Color get _statusColor {
    switch (sale.status) {
      case SalePaymentStatus.paid:
        return Colors.green;
      case SalePaymentStatus.credit:
        return Colors.redAccent;
      case SalePaymentStatus.partial:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dividerGray.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_long_outlined,
                color: _statusColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sale.itemDescription,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlue)),
                const SizedBox(height: 2),
                Text(
                  '${sale.date.day}/${sale.date.month}/${sale.date.year}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.grayText),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs ${sale.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlue),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sale.statusLabel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
