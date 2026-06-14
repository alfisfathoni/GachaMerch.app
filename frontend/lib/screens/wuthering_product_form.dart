import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../theme.dart';

class WutheringProductForm extends StatefulWidget {
  final Product? existingProduct;
  const WutheringProductForm({super.key, this.existingProduct});

  @override
  State<WutheringProductForm> createState() => _WutheringProductFormState();
}

class _WutheringProductFormState extends State<WutheringProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageUrlController;
  late String _selectedCategory;
  bool _isLoading = false;

  bool get _isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _stockController =
        TextEditingController(text: p != null ? p.stock.toString() : '');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _selectedCategory = p?.category ?? 'Resonator Equipment';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final pp = Provider.of<ProductProvider>(context, listen: false);

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final imageUrl = _imageUrlController.text.trim();
    final token = auth.token;

    Map<String, dynamic> result;

    if (_isEditing) {
      result = await pp.updateProduct(
        token: token,
        id: widget.existingProduct!.id,
        name: name,
        description: desc,
        price: price,
        stock: stock,
        category: _selectedCategory,
        imageUrl: imageUrl,
      );
    } else {
      result = await pp.createProduct(
        token: token,
        name: name,
        description: desc,
        price: price,
        stock: stock,
        category: _selectedCategory,
        imageUrl: imageUrl,
      );
    }

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (result['success'] == true) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.cardColor,
          content: Text(
            '✓ ${_isEditing ? "Item updated" : "Item created"} successfully.',
            style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.greenAccent, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2D0000),
          content: Text(
            '✗ ${result['message']}',
            style: const TextStyle(fontFamily: 'monospace', color: Colors.redAccent),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Item name cannot be empty.';
    if (v.trim().length < 3) return 'Item name must be at least 3 characters.';
    return null;
  }

  String? _validateDesc(String? v) {
    if (v == null || v.trim().isEmpty) return 'Description cannot be empty.';
    return null;
  }

  String? _validatePrice(String? v) {
    if (v == null || v.trim().isEmpty) return 'Price is required.';
    final parsed = double.tryParse(v.trim());
    if (parsed == null) return 'Price must be a valid number.';
    if (parsed <= 0) return 'Price must be greater than 0.';
    return null;
  }

  String? _validateStock(String? v) {
    if (v == null || v.trim().isEmpty) return 'Stock is required.';
    final parsed = int.tryParse(v.trim());
    if (parsed == null) return 'Stock must be a whole number.';
    if (parsed < 0) return 'Stock cannot be negative.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.02,
              child: GridPaper(
                color: AppTheme.primaryColor,
                interval: 40,
                divisions: 1,
                subdivisions: 1,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white54, size: 16),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? 'EDIT CATALOG ENTRY' : 'NEW CATALOG ENTRY',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _isEditing
                                ? 'ID: #${widget.existingProduct!.id}'
                                : 'INSERT INTO products',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              color: AppTheme.accentColor.withOpacity(0.7),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _FormSection(
                            label: '01 // ITEM NAME',
                            child: TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              validator: _validateName,
                              decoration: _inputDecoration('e.g. Verdant Summit'),
                            ),
                          ),
                          _FormSection(
                            label: '02 // DESCRIPTION',
                            child: TextFormField(
                              controller: _descController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              validator: _validateDesc,
                              maxLines: 3,
                              decoration: _inputDecoration(
                                  'Describe this item\'s resonance capabilities...'),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _FormSection(
                                  label: '03 // PRICE (IDR)',
                                  child: TextFormField(
                                    controller: _priceController,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                    validator: _validatePrice,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                                    ],
                                    decoration: _inputDecoration('e.g. 648000'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FormSection(
                                  label: '04 // STOCK (units)',
                                  child: TextFormField(
                                    controller: _stockController,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                    validator: _validateStock,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: _inputDecoration('e.g. 50'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _FormSection(
                            label: '05 // CATEGORY',
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.containerBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCategory,
                                  dropdownColor: AppTheme.cardColor,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Resonator Equipment',
                                        child: Text('RESONATOR EQUIPMENT')),
                                    DropdownMenuItem(
                                        value: 'Supplies',
                                        child: Text('SUPPLIES')),
                                  ],
                                  onChanged: (v) => setState(() => _selectedCategory = v!),
                                ),
                              ),
                            ),
                          ),
                          _FormSection(
                            label: '06 // IMAGE KEY (optional)',
                            child: TextFormField(
                              controller: _imageUrlController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: _inputDecoration('e.g. verdant_summit'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: _isLoading ? null : _submit,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: _isLoading
                                    ? null
                                    : const LinearGradient(
                                        colors: [AppTheme.primaryColor, Color(0xFFE8C26E)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                color: _isLoading ? AppTheme.borderColor : null,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: _isLoading
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withOpacity(0.35),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        _isEditing ? 'COMMIT UPDATE' : 'INSERT RECORD',
                                        style: const TextStyle(
                                          color: AppTheme.darkBg,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          letterSpacing: 2,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
      fillColor: Colors.black.withOpacity(0.35),
      errorStyle: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 10,
        color: Colors.redAccent,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 2,
                  height: 10,
                  color: AppTheme.accentColor.withOpacity(0.7)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
