import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/app_colors.dart';
import '../../view_models/cash_flow_controller.dart';

class SendMoneySheet extends StatelessWidget {
  SendMoneySheet({super.key});

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashFlowController>(
      builder: (ctrl) => _CashFlowSheetBody(
        title: 'Send Money',
        icon: Icons.arrow_upward_rounded,
        iconColor: Colors.blue,
        formKey: _formKey,
        isSubmitting: ctrl.isSubmitting,
        fields: [
          _buildField(_titleCtrl, 'Recipient / Title', Icons.person_outline),
          const SizedBox(height: 12),
          _buildField(_subtitleCtrl, 'Note (e.g. Invoice #204)', Icons.note_outlined),
          const SizedBox(height: 12),
          _buildAmountField(_amountCtrl),
        ],
        onSubmit: () async {
          if (_formKey.currentState!.validate()) {
            await ctrl.recordSend(
              title: _titleCtrl.text.trim(),
              subtitle: _subtitleCtrl.text.trim(),
              amount: double.parse(_amountCtrl.text.trim()),
            );
            Get.back();
          }
        },
        buttonLabel: 'Send',
        buttonGradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
      ),
    );
  }
}

class ReceiveMoneySheet extends StatelessWidget {
  ReceiveMoneySheet({super.key});

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashFlowController>(
      builder: (ctrl) => _CashFlowSheetBody(
        title: 'Received Payment',
        icon: Icons.arrow_downward_rounded,
        iconColor: Colors.green,
        formKey: _formKey,
        isSubmitting: ctrl.isSubmitting,
        fields: [
          _buildField(_titleCtrl, 'Payer / Client Name', Icons.business_outlined),
          const SizedBox(height: 12),
          _buildField(_subtitleCtrl, 'Note (e.g. Invoice #101)', Icons.note_outlined),
          const SizedBox(height: 12),
          _buildAmountField(_amountCtrl),
        ],
        onSubmit: () async {
          if (_formKey.currentState!.validate()) {
            await ctrl.recordReceive(
              title: _titleCtrl.text.trim(),
              subtitle: _subtitleCtrl.text.trim(),
              amount: double.parse(_amountCtrl.text.trim()),
            );
            Get.back();
          }
        },
        buttonLabel: 'Record',
        buttonGradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
      ),
    );
  }
}

class AddMoneySheet extends StatelessWidget {
  AddMoneySheet({super.key});

  final _formKey = GlobalKey<FormState>();
  final _sourceCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CashFlowController>(
      builder: (ctrl) => _CashFlowSheetBody(
        title: 'Add Money',
        icon: Icons.add_rounded,
        iconColor: AppColors.accentOrange,
        formKey: _formKey,
        isSubmitting: ctrl.isSubmitting,
        fields: [
          _buildField(_sourceCtrl, 'Source (e.g. Bank Transfer)', Icons.account_balance_outlined),
          const SizedBox(height: 12),
          _buildAmountField(_amountCtrl),
        ],
        onSubmit: () async {
          if (_formKey.currentState!.validate()) {
            await ctrl.addMoney(
              source: _sourceCtrl.text.trim(),
              amount: double.parse(_amountCtrl.text.trim()),
            );
            Get.back();
          }
        },
        buttonLabel: 'Add',
        buttonGradient: AppColors.orangeGradient,
      ),
    );
  }
}

// ── Shared sheet body ──────────────────────────────────────────────────────────

class _CashFlowSheetBody extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final GlobalKey<FormState> formKey;
  final bool isSubmitting;
  final List<Widget> fields;
  final VoidCallback onSubmit;
  final String buttonLabel;
  final Gradient buttonGradient;

  const _CashFlowSheetBody({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.formKey,
    required this.isSubmitting,
    required this.fields,
    required this.onSubmit,
    required this.buttonLabel,
    required this.buttonGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: formKey,
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...fields,
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: buttonGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          buttonLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared field builders ──────────────────────────────────────────────────────

Widget _buildField(
    TextEditingController ctrl, String label, IconData icon) {
  return TextFormField(
    controller: ctrl,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.iconBlue, size: 20),
      filled: true,
      fillColor: AppColors.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
  );
}

Widget _buildAmountField(TextEditingController ctrl) {
  return TextFormField(
    controller: ctrl,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: 'Amount (\$)',
      prefixIcon:
          const Icon(Icons.attach_money_rounded, color: AppColors.iconBlue, size: 20),
      filled: true,
      fillColor: AppColors.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    validator: (v) {
      if (v == null || v.trim().isEmpty) return 'Required';
      final n = double.tryParse(v.trim());
      if (n == null || n <= 0) return 'Enter a valid amount';
      return null;
    },
  );
}
