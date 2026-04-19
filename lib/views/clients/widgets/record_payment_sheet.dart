import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/client_sale_model.dart';
import '../../../res/app_colors.dart';
import '../../../view_models/client_controller.dart';

class RecordPaymentSheet extends StatefulWidget {
  final ClientSaleModel sale;
  final ClientController ctrl;

  const RecordPaymentSheet(
      {super.key, required this.sale, required this.ctrl});

  @override
  State<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends State<RecordPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();

  double get _maxPayable => widget.sale.pendingAmount;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;

    return GetBuilder<ClientController>(
      builder: (ctrl) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.payments_outlined,
                        color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Record Payment',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlue)),
                ],
              ),
              const SizedBox(height: 20),

              // Sale summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sale.itemDescription,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlue)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _InfoChip(
                            label: 'Total',
                            value:
                                'Rs ${sale.totalAmount.toStringAsFixed(0)}'),
                        _InfoChip(
                            label: 'Paid',
                            value:
                                'Rs ${sale.paidAmount.toStringAsFixed(0)}',
                            valueColor: Colors.green),
                        _InfoChip(
                            label: 'Pending',
                            value:
                                'Rs ${sale.pendingAmount.toStringAsFixed(0)}',
                            valueColor: Colors.redAccent),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment amount field
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Payment Amount',
                  hintText: 'Max: Rs ${_maxPayable.toStringAsFixed(0)}',
                  prefixIcon: const Icon(Icons.attach_money_rounded,
                      color: AppColors.iconBlue, size: 20),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = double.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  if (n > _maxPayable) {
                    return 'Cannot exceed pending Rs ${_maxPayable.toStringAsFixed(0)}';
                  }
                  return null;
                },
              ),

              // Quick-fill full amount button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _amountCtrl.text =
                      _maxPayable.toStringAsFixed(0),
                  child: Text(
                    'Pay full (Rs ${_maxPayable.toStringAsFixed(0)})',
                    style: const TextStyle(
                        color: AppColors.primaryBlue, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ElevatedButton(
                    onPressed: ctrl.isSubmitting
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              await ctrl.recordPayment(
                                clientId: sale.clientId,
                                saleId: sale.id,
                                paymentAmount: double.parse(
                                    _amountCtrl.text.trim()),
                                currentPaid: sale.paidAmount,
                                totalAmount: sale.totalAmount,
                              );
                              Get.back();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: ctrl.isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Confirm Payment',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoChip(
      {required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.grayText)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppColors.textBlue)),
      ],
    );
  }
}
