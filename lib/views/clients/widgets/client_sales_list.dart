import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/client_model.dart';
import '../../../models/client_sale_model.dart';
import '../../../res/app_colors.dart';
import '../../../view_models/client_controller.dart';
import '../purchase_details_screen.dart';

class ClientSalesList extends StatelessWidget {
  final String clientId;
  final ClientController ctrl;
  final ClientModel client;
  final Set<String> selectedSaleIds;
  final Function(String) onSelect;
  final Function(String) onLongPress;

  const ClientSalesList({
    super.key, 
    required this.clientId, 
    required this.ctrl,
    required this.client,
    required this.selectedSaleIds,
    required this.onSelect,
    required this.onLongPress,
  });

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
      itemBuilder: (_, i) {
        final sale = sales[i];
        final isSelected = selectedSaleIds.contains(sale.id);
        
        return GestureDetector(
          onLongPress: () => onLongPress(sale.id),
          onTap: () {
            if (selectedSaleIds.isNotEmpty) {
              onSelect(sale.id);
            } else {
              Get.to(() => PurchaseDetailsScreen(sale: sale, client: client));
            }
          },
          child: _SaleTile(sale: sale, isSelected: isSelected),
        );
      },
    );
  }
}

class _SaleTile extends StatelessWidget {
  final ClientSaleModel sale;
  final bool isSelected;
  const _SaleTile({required this.sale, required this.isSelected});

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
        color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.dividerGray.withOpacity(0.5),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Stack(
        children: [
          Row(
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
      if (isSelected)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }
}
