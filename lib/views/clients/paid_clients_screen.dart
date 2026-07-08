import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/client_sale_model.dart';
import '../../res/app_colors.dart';
import '../../view_models/client_controller.dart';

class PaidClientsScreen extends StatelessWidget {
  const PaidClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Payments Received',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: GetBuilder<ClientController>(
        builder: (ctrl) {
          final paid = ctrl.allPaidSales;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
            children: [
              // ── Summary banner ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  gradient: AppColors.navyGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Collected',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      'PKR ${ctrl.totalClientPayments.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.greenAccent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${paid.length} fully paid transactions',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── List ───────────────────────────────────────────────
              Expanded(
                child: paid.isEmpty
                    ? const _EmptyPaid()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: paid.length,
                        itemBuilder: (_, i) {
                          final sale = paid[i];
                          final clientId =
                              sale['clientId'] as String? ?? '';
                          // Find client name from cache
                          final client = ctrl.allClients
                              .where((c) => c.id == clientId)
                              .firstOrNull;
                          final clientName =
                              client?.name ?? 'Unknown Client';

                          return _PaidSaleTile(
                            sale: sale,
                            clientName: clientName,
                          );
                        },
                      ),
              ),
            ],
          ),
            ),
          );
        },
      ),
    );
  }
}

// ── Paid sale tile ─────────────────────────────────────────────────────────────

class _PaidSaleTile extends StatelessWidget {
  final Map<String, dynamic> sale;
  final String clientName;

  const _PaidSaleTile(
      {required this.sale, required this.clientName});

  @override
  Widget build(BuildContext context) {
    final paidAmount =
        (sale['paidAmount'] as num?)?.toDouble() ?? 0;
    final totalAmount =
        (sale['totalAmount'] as num?)?.toDouble() ?? 0;
    final description =
        sale['itemDescription'] as String? ?? '';
    final date = sale['date'] != null
        ? (sale['date'] as dynamic).toDate() as DateTime
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Green paid icon ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),

          // ── Info ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client name + Paid badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        clientName,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlue),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.green.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'PAID',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.green,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.grayText),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.grayText),
                ),
              ],
            ),
          ),

          // ── Amount ───────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'PKR ${paidAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              if (totalAmount != paidAmount)
                Text(
                  'of PKR ${totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.grayText),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyPaid extends StatelessWidget {
  const _EmptyPaid();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payments_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No payments received yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grayText)),
          const SizedBox(height: 8),
          const Text('Paid client sales will appear here',
              style: TextStyle(fontSize: 13, color: AppColors.grayText)),
        ],
      ),
    );
  }
}
