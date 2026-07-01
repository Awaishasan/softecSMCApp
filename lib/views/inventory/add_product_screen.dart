import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/inventory_item.dart';
import '../../res/app_colors.dart';
import '../../view_models/inventory_controller.dart';

class AddProductScreen extends StatefulWidget {
  final InventoryItem? item;

  const AddProductScreen({super.key, this.item});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _costPriceCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _lowStockThresholdCtrl = TextEditingController();
  final _newCategoryCtrl = TextEditingController();

  String? _selectedCategory;
  File? _pickedImageFile;
  String? _existingImageUrl;
  bool _isUploadingImage = false;

  // Returns only real categories (no 'All')
  List<String> get _realCategories {
    final ctrl = Get.find<InventoryController>();
    return ctrl.categories.where((c) => c != 'All').toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      final item = widget.item!;
      _nameCtrl.text = item.name;
      _skuCtrl.text = item.sku;
      _barcodeCtrl.text = item.barcode ?? '';
      _costPriceCtrl.text = item.costPrice.toString();
      _sellingPriceCtrl.text = item.sellingPrice.toString();
      _quantityCtrl.text = item.quantity.toString();
      _lowStockThresholdCtrl.text = item.lowStockThreshold.toString();
      _existingImageUrl = item.imageUrl;
      // Validate that category still exists
      final cats = _realCategories;
      _selectedCategory = cats.contains(item.category) ? item.category : (cats.isNotEmpty ? cats.first : null);
    } else {
      final cats = _realCategories;
      _selectedCategory = cats.isNotEmpty ? cats.first : null;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    _costPriceCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _quantityCtrl.dispose();
    _lowStockThresholdCtrl.dispose();
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  // ─── Image Picker ───────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (picked != null && mounted) {
        setState(() => _pickedImageFile = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text('Select Image Source',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _imageSourceOption(Icons.camera_alt_rounded, 'Camera', () async {
                    Navigator.of(sheetCtx).pop();
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (mounted) _pickImage(ImageSource.camera);
                  }),
                  _imageSourceOption(Icons.photo_library_rounded, 'Gallery', () async {
                    Navigator.of(sheetCtx).pop();
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (mounted) _pickImage(ImageSource.gallery);
                  }),
                  if (_pickedImageFile != null || _existingImageUrl != null)
                    _imageSourceOption(Icons.delete_rounded, 'Remove', () {
                      Navigator.of(sheetCtx).pop();
                      if (mounted) {
                        setState(() {
                          _pickedImageFile = null;
                          _existingImageUrl = null;
                        });
                      }
                    }, color: Colors.red),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSourceOption(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final c = color ?? AppColors.primaryBlue;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: c.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: c, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: c, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<String?> _uploadImage() async {
    if (_pickedImageFile == null) return _existingImageUrl;
    setState(() => _isUploadingImage = true);
    try {
      // Try Firebase Storage first
      final fileName = 'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(_pickedImageFile!);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Firebase Storage upload failed: $e');
      debugPrint('Falling back to base64 encoding...');
      // Fallback: convert image to base64 data URI so imageUrl is never null
      try {
        final bytes = await _pickedImageFile!.readAsBytes();
        final base64Str = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64Str';
      } catch (base64Error) {
        debugPrint('Base64 encoding also failed: $base64Error');
        return _existingImageUrl;
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  // ─── Category ────────────────────────────────────────────────────────────────

  void _showAddCategoryDialog() {
    _newCategoryCtrl.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextFormField(
          controller: _newCategoryCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Electronics',
            filled: true,
            fillColor: AppColors.backgroundLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final cat = _newCategoryCtrl.text.trim();
              if (cat.isNotEmpty) {
                Get.back();
                setState(() => _selectedCategory = cat);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submit(InventoryController ctrl) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or create a category')),
      );
      return;
    }

    final imageUrl = await _uploadImage();

    if (widget.item == null) {
      await ctrl.addItem(
        name: _nameCtrl.text.trim(),
        category: _selectedCategory!,
        sku: _skuCtrl.text.trim(),
        barcode: _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim(),
        costPrice: double.parse(_costPriceCtrl.text.trim()),
        sellingPrice: double.parse(_sellingPriceCtrl.text.trim()),
        quantity: int.parse(_quantityCtrl.text.trim()),
        lowStockThreshold: int.parse(_lowStockThresholdCtrl.text.trim()),
        imageUrl: imageUrl,
      );
    } else {
      await ctrl.updateItem(widget.item!.copyWith(
        name: _nameCtrl.text.trim(),
        category: _selectedCategory,
        sku: _skuCtrl.text.trim(),
        barcode: _barcodeCtrl.text.trim().isEmpty ? null : _barcodeCtrl.text.trim(),
        costPrice: double.parse(_costPriceCtrl.text.trim()),
        sellingPrice: double.parse(_sellingPriceCtrl.text.trim()),
        quantity: int.parse(_quantityCtrl.text.trim()),
        lowStockThreshold: int.parse(_lowStockThresholdCtrl.text.trim()),
        imageUrl: imageUrl,
        updatedAt: DateTime.now(),
      ));
    }

    if (!ctrl.isSubmitting) {
      Get.back();
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InventoryController>(
      builder: (ctrl) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textBlue),
            onPressed: Get.back,
          ),
          title: Text(
            widget.item == null ? 'Add Product' : 'Edit Product',
            style: const TextStyle(
              color: AppColors.textBlue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image Section ─────────────────────────────────────────────
                _buildImageSection(),
                const SizedBox(height: 28),

                // ── Basic Info ────────────────────────────────────────────────
                _sectionLabel('Basic Information'),
                const SizedBox(height: 12),
                _buildTextField(_nameCtrl, 'Product Name', Icons.inventory_2_outlined),
                const SizedBox(height: 12),
                _buildTextField(_skuCtrl, 'SKU', Icons.tag),
                const SizedBox(height: 12),
                _buildTextField(_barcodeCtrl, 'Barcode (Optional)', Icons.qr_code, required: false),
                const SizedBox(height: 24),

                // ── Category ──────────────────────────────────────────────────
                _sectionLabel('Category'),
                const SizedBox(height: 12),
                _buildCategoryField(ctrl),
                const SizedBox(height: 24),

                // ── Pricing ───────────────────────────────────────────────────
                _sectionLabel('Pricing'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_costPriceCtrl, 'Cost Price', Icons.attach_money,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_sellingPriceCtrl, 'Selling Price', Icons.sell,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Stock ─────────────────────────────────────────────────────
                _sectionLabel('Stock'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_quantityCtrl, 'Quantity', Icons.inventory,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_lowStockThresholdCtrl, 'Low Stock Alert',
                        Icons.warning_amber_outlined,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false))),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Save Button ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (ctrl.isSubmitting || _isUploadingImage) ? null : () => _submit(ctrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    child: (ctrl.isSubmitting || _isUploadingImage)
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            widget.item == null ? 'Add Product' : 'Update Product',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Widgets ─────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.grayText,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildImageSection() {
    final hasImage = _pickedImageFile != null || (_existingImageUrl != null && _existingImageUrl!.isNotEmpty);
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? AppColors.primaryBlue.withOpacity(0.4) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  if (_pickedImageFile != null)
                    Image.file(_pickedImageFile!, fit: BoxFit.cover)
                  else if (_existingImageUrl!.startsWith('data:image'))
                    Image.memory(
                      base64Decode(_existingImageUrl!.split(',').last),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  else
                    Image.network(
                      _existingImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    ),
                  Positioned(
                    bottom: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Change', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_photo_alternate_rounded,
              color: AppColors.primaryBlue, size: 30),
        ),
        const SizedBox(height: 12),
        const Text('Add Product Image',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textBlue)),
        const SizedBox(height: 4),
        const Text('Tap to choose from gallery or camera',
            style: TextStyle(fontSize: 12, color: AppColors.grayText)),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = true,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.iconBlue, size: 20),
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (keyboardType == const TextInputType.numberWithOptions(decimal: true) ||
                  keyboardType == const TextInputType.numberWithOptions(decimal: false)) {
                final parsed = double.tryParse(v.trim());
                if (parsed == null) return 'Invalid number';
                if (parsed < 0) return 'Cannot be negative';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildCategoryField(InventoryController ctrl) {
    final cats = _realCategories;

    // Ensure _selectedCategory is always valid
    if (_selectedCategory != null && !cats.contains(_selectedCategory)) {
      // The category typed manually (new one) — keep it as-is
    }

    return Row(
      children: [
        Expanded(
          child: cats.isEmpty
              ? // No existing categories — show a text hint
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.category, color: AppColors.iconBlue, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _selectedCategory ?? 'No categories yet',
                        style: TextStyle(
                          color: _selectedCategory != null
                              ? AppColors.textBlue
                              : AppColors.grayText,
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonFormField<String>(
                  value: cats.contains(_selectedCategory) ? _selectedCategory : null,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category, color: AppColors.iconBlue, size: 20),
                    filled: true,
                    fillColor: AppColors.backgroundLight,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    ),
                  ),
                  // Deduplicate items to avoid assertion error
                  items: cats.toSet().map((cat) =>
                    DropdownMenuItem(value: cat, child: Text(cat))
                  ).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedCategory = value);
                  },
                  validator: (_) {
                    if (_selectedCategory == null || _selectedCategory!.isEmpty) return 'Required';
                    return null;
                  },
                ),
        ),
        const SizedBox(width: 8),
        // "+" button to add a new category
        GestureDetector(
          onTap: _showAddCategoryDialog,
          child: Container(
            width: 52, height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_rounded, color: AppColors.primaryBlue, size: 24),
          ),
        ),
      ],
    );
  }
}
