import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/client_sale_model.dart';
import '../../../models/inventory_item.dart';
import '../../../res/app_colors.dart';
import '../../../view_models/client_controller.dart';
import '../../../view_models/inventory_controller.dart';
import '../../inventory/product_selection_sheet.dart';

class AddSaleSheet extends StatefulWidget {
  final String clientId;
  final String clientName;

  const AddSaleSheet(
      {super.key, required this.clientId, required this.clientName});

  @override
  State<AddSaleSheet> createState() => _AddSaleSheetState();
}

class _AddSaleSheetState extends State<AddSaleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _itemCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  InventoryItem? _selectedProduct;
  SalePaymentStatus _status = SalePaymentStatus.paid;
  DateTime? _dueDate;
  DiscountType _discountType = DiscountType.fixed;

  @override
  void dispose() {
    _itemCtrl.dispose();
    _totalCtrl.dispose();
    _paidCtrl.dispose();
    _quantityCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  void _onProductSelected(InventoryItem product) {
    setState(() {
      _selectedProduct = product;
      _itemCtrl.text = product.name;
      _totalCtrl.text = product.sellingPrice.toString();
      _quantityCtrl.text = '1';
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    if (_selectedProduct == null) return;
    
    final quantity = int.tryParse(_quantityCtrl.text) ?? 1;
    final discount = double.tryParse(_discountCtrl.text) ?? 0;
    
    double subtotal = _selectedProduct!.sellingPrice * quantity;
    
    if (_discountType == DiscountType.percentage) {
      subtotal = subtotal - (subtotal * discount / 100);
    } else {
      subtotal = subtotal - discount;
    }
    
    setState(() {
      _totalCtrl.text = subtotal.toStringAsFixed(2);
    });
  }

  // Auto-derive status from paid vs total amounts
  void _updateStatus() {
    final total = double.tryParse(_totalCtrl.text) ?? 0;
    final paid = double.tryParse(_paidCtrl.text) ?? 0;
    setState(() {
      if (paid <= 0) {
        _status = SalePaymentStatus.credit;
      } else if (paid >= total) {
        _status = SalePaymentStatus.paid;
      } else {
        _status = SalePaymentStatus.partial;
      }
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryBlue,
            onPrimary: Colors.white,
            onSurface: AppColors.textBlue,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
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

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.receipt_long_outlined,
                          color: AppColors.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Add Sale',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlue)),
                        Text(widget.clientName,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.grayText)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Product Selection
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ProductSelectionSheet(
                        onProductSelected: _onProductSelected,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: AppColors.iconBlue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedProduct?.name ?? 'Select Product',
                            style: TextStyle(
                              color: _selectedProduct != null ? AppColors.textBlue : AppColors.grayText,
                              fontWeight: _selectedProduct != null ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.iconBlue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Quantity (only shown when product is selected)
                if (_selectedProduct != null) ...[
                  _buildAmountField(
                    _quantityCtrl,
                    'Quantity',
                    keyboardType: TextInputType.numberWithOptions(decimal: false),
                    onChanged: (_) => _calculateTotal(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Discount (only shown when product is selected)
                if (_selectedProduct != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildAmountField(
                          _discountCtrl,
                          'Discount',
                          required: false,
                          onChanged: (_) => _calculateTotal(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.iconBlue.withOpacity(0.3)),
                        ),
                        child: DropdownButton<DiscountType>(
                          value: _discountType,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(value: DiscountType.fixed, child: Text('Rs')),
                            DropdownMenuItem(value: DiscountType.percentage, child: Text('%')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _discountType = value;
                                _calculateTotal();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Total Amount (read-only when product is selected)
                _buildAmountField(
                  _totalCtrl,
                  'Total Amount',
                  readOnly: _selectedProduct != null,
                  onChanged: (_) => _updateStatus(),
                ),
                const SizedBox(height: 12),


                _buildAmountField(
                  _paidCtrl,
                  'Amount Paid (0 if full credit)',
                  onChanged: (_) => _updateStatus(),
                  required: false,
                ),
                const SizedBox(height: 16),


                Row(
                  children: [
                    const Text('Status: ',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.grayText)),
                    _StatusBadge(status: _status),
                  ],
                ),
                const SizedBox(height: 16),

                if (_status != SalePaymentStatus.paid) ...[
                  GestureDetector(
                    onTap: _pickDueDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.iconBlue, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            _dueDate != null
                                ? 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                : 'Set Due Date (optional)',
                            style: TextStyle(
                              fontSize: 14,
                              color: _dueDate != null
                                  ? AppColors.textBlue
                                  : AppColors.grayText,
                            ),
                          ),
                          const Spacer(),
                          if (_dueDate != null)
                            GestureDetector(
                              onTap: () => setState(() => _dueDate = null),
                              child: const Icon(Icons.close,
                                  size: 16, color: AppColors.grayText),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],


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
                                final total = double.parse(
                                    _totalCtrl.text.trim());
                                final paid = double.tryParse(
                                        _paidCtrl.text.trim()) ??
                                    0;
                                
                                // Prepare inventory data if product is selected
                                final quantity = _selectedProduct != null 
                                    ? int.tryParse(_quantityCtrl.text) ?? 1 
                                    : null;
                                final discount = _selectedProduct != null
                                    ? double.tryParse(_discountCtrl.text) ?? 0
                                    : null;
                                
                                await ctrl.addSale(
                                  clientId: widget.clientId,
                                  itemDescription: _itemCtrl.text.trim(),
                                  totalAmount: total,
                                  paidAmount: paid,
                                  status: _status,
                                  dueDate: _dueDate,
                                  // Inventory fields
                                  inventoryItemId: _selectedProduct?.id,
                                  productName: _selectedProduct?.name,
                                  quantity: quantity,
                                  unitPrice: _selectedProduct?.sellingPrice,
                                  discount: discount,
                                  discountType: _discountType,
                                  finalAmount: total,
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
                          : const Text('Record Sale',
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



Widget _buildField(
  TextEditingController ctrl,
  String label,
  IconData icon, {
  bool required = true,
}) {
  return TextFormField(
    controller: ctrl,
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

Widget _buildAmountField(
  TextEditingController ctrl,
  String label, {
  void Function(String)? onChanged,
  bool required = true,
  bool readOnly = false,
  TextInputType? keyboardType,
}) {
  return TextFormField(
    controller: ctrl,
    keyboardType: keyboardType ?? const TextInputType.numberWithOptions(decimal: true),
    onChanged: onChanged,
    readOnly: readOnly,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.attach_money_rounded,
          color: AppColors.iconBlue, size: 20),
      filled: true,
      fillColor: readOnly ? AppColors.backgroundLight.withOpacity(0.5) : AppColors.backgroundLight,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
    ),
    validator: required
        ? (v) {
            if (v == null || v.trim().isEmpty) return 'Required';
            if (double.tryParse(v.trim()) == null) return 'Invalid number';
            return null;
          }
        : null,
  );
}

class _StatusBadge extends StatelessWidget {
  final SalePaymentStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
