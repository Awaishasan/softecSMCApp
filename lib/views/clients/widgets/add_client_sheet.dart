import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/client_model.dart';
import '../../../res/app_colors.dart';
import '../../../view_models/client_controller.dart';

class AddClientSheet extends StatefulWidget {
  const AddClientSheet({super.key});

  @override
  State<AddClientSheet> createState() => _AddClientSheetState();
}

class _AddClientSheetState extends State<AddClientSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  ClientType _selectedType = ClientType.walkIn;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (ctrl) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SheetHandle(),
                const SizedBox(height: 20),
                const Text('Add New Client',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlue)),
                const SizedBox(height: 20),
                _field(_nameCtrl, 'Full Name', Icons.person_outline),
                const SizedBox(height: 12),
                _field(_phoneCtrl, 'Phone Number', Icons.phone_outlined,
                    keyboard: TextInputType.phone),
                const SizedBox(height: 12),
                _field(_emailCtrl, 'Email (optional)', Icons.email_outlined,
                    required: false),
                const SizedBox(height: 12),
                _field(_addressCtrl, 'Address (optional)',
                    Icons.location_on_outlined,
                    required: false),
                const SizedBox(height: 16),

                // Client type selector
                const Text('Client Type',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grayText)),
                const SizedBox(height: 8),
                Row(
                  children: ClientType.values.map((t) {
                    final selected = _selectedType == t;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryBlue
                                : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primaryBlue
                                  : AppColors.dividerGray,
                            ),
                          ),
                          child: Text(
                            t.name[0].toUpperCase() + t.name.substring(1),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppColors.grayText,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.navyGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      onPressed: ctrl.isSubmitting
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                await ctrl.addClient(
                                  name: _nameCtrl.text.trim(),
                                  phone: _phoneCtrl.text.trim(),
                                  email: _emailCtrl.text.trim(),
                                  address: _addressCtrl.text.trim(),
                                  type: _selectedType,
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
                          : const Text('Add Client',
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
      ),
    );
  }
}

Widget _field(
  TextEditingController ctrl,
  String label,
  IconData icon, {
  TextInputType keyboard = TextInputType.text,
  bool required = true,
}) {
  return TextFormField(
    controller: ctrl,
    keyboardType: keyboard,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.iconBlue, size: 20),
      filled: true,
      fillColor: AppColors.backgroundLight,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
    ),
    validator: required
        ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
        : null,
  );
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2)),
        ),
      );
}
