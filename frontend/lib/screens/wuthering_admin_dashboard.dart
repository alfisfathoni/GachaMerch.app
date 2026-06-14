import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../theme.dart';
import 'wuthering_login_page.dart';
import 'wuthering_product_form.dart';

class WutheringAdminDashboard extends StatefulWidget {
  const WutheringAdminDashboard({super.key});

  @override
  State<WutheringAdminDashboard> createState() => _WutheringAdminDashboardState();
}

class _WutheringAdminDashboardState extends State<WutheringAdminDashboard> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Resonator Equipment', 'Supplies'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WutheringLoginPage()),
      (route) => false,
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A0000),
          shape: const BeveledRectangleBorder(
            side: BorderSide(color: Colors.redAccent, width: 1.5),
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          title: const Row(
            children: [
              Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(
                'PURGE RECORD',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  color: Colors.redAccent,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          content: Text(
            'Permanently delete "${product.name}" from the database? This action cannot be reversed.',
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('ABORT', style: TextStyle(color: Colors.white54, letterSpacing: 1)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final token = Provider.of<AuthProvider>(context, listen: false).token;
                final result = await Provider.of<ProductProvider>(context, listen: false)
                    .deleteProduct(token: token, id: product.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: result['success'] == true
                        ? AppTheme.cardColor
                        : const Color(0xFF2D0000),
                    content: Text(
                      result['success'] == true
                          ? '✓ ${product.name} purged from catalog.'
                          : '✗ ${result['message']}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('CONFIRM PURGE',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm({Product? product}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WutheringProductForm(existingProduct: product),
      ),
    );
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
                color: AppTheme.accentColor,
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme.primaryColor.withOpacity(0.08),
                        ),
                        child: const Icon(Icons.shield_outlined,
                            color: AppTheme.primaryColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ADMIN TERMINAL',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'WUTHERING MERCH CONTROL',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 9,
                              color: AppTheme.accentColor.withOpacity(0.8),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Provider.of<ProductProvider>(context,
                                listen: false)
                            .fetchProducts(),
                        icon: const Icon(Icons.refresh_rounded,
                            color: AppTheme.accentColor, size: 20),
                        tooltip: 'Refresh catalog',
                      ),
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded,
                            color: Colors.white38, size: 20),
                        tooltip: 'Disconnect',
                      ),
                    ],
                  ),
                ),
                Consumer<ProductProvider>(
                  builder: (_, pp, __) {
                    final totalStock =
                        pp.products.fold<int>(0, (s, p) => s + p.stock);
                    final lowStock = pp.products.where((p) => p.stock < 20).length;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        children: [
                          _StatChip(
                              label: 'ITEMS',
                              value: '${pp.products.length}',
                              icon: Icons.inventory_2_outlined,
                              color: AppTheme.primaryColor),
                          const SizedBox(width: 10),
                          _StatChip(
                              label: 'TOTAL STOCK',
                              value: '$totalStock',
                              icon: Icons.warehouse_outlined,
                              color: AppTheme.accentColor),
                          const SizedBox(width: 10),
                          _StatChip(
                              label: 'LOW STOCK',
                              value: '$lowStock',
                              icon: Icons.warning_amber_outlined,
                              color: lowStock > 0
                                  ? Colors.orangeAccent
                                  : Colors.green),
                        ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                          decoration: InputDecoration(
                            hintText: 'Search catalog...',
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3), fontSize: 12),
                            prefixIcon: Icon(Icons.search,
                                color: Colors.white.withOpacity(0.3), size: 18),
                            fillColor: Colors.black.withOpacity(0.4),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            dropdownColor: AppTheme.cardColor,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                            items: _categories
                                .map((c) => DropdownMenuItem(
                                    value: c, child: Text(c.toUpperCase())))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedCategory = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Consumer<ProductProvider>(
                    builder: (_, pp, __) {
                      if (pp.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor),
                          ),
                        );
                      }
                      final filtered = pp.products.where((p) {
                        final matchSearch =
                            p.name.toLowerCase().contains(_searchQuery) ||
                                p.description
                                    .toLowerCase()
                                    .contains(_searchQuery);
                        final matchCat = _selectedCategory == 'All' ||
                            p.category == _selectedCategory;
                        return matchSearch && matchCat;
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 48,
                                  color: Colors.white.withOpacity(0.15)),
                              const SizedBox(height: 12),
                              Text(
                                'NO RECORDS FOUND',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.white.withOpacity(0.3),
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final p = filtered[i];
                          return _ProductListTile(
                            product: p,
                            onEdit: () => _navigateToForm(product: p),
                            onDelete: () => _confirmDelete(context, p),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            right: 20,
            child: GestureDetector(
              onTap: () => _navigateToForm(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFFE8C26E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: AppTheme.darkBg, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'ADD ITEM',
                      style: TextStyle(
                        color: AppTheme.darkBg,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      color: color.withOpacity(0.7),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductListTile({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _categoryColor {
    return product.category == 'Resonator Equipment'
        ? AppTheme.primaryColor
        : AppTheme.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stock < 20;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isLowStock
              ? Colors.orangeAccent.withOpacity(0.3)
              : AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 48,
              decoration: BoxDecoration(
                color: _categoryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _categoryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                              color: _categoryColor.withOpacity(0.3), width: 0.5),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 8,
                            color: _categoryColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'STK: ${product.stock}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: isLowStock
                              ? Colors.orangeAccent
                              : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${(product.price / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppTheme.accentColor.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            color: AppTheme.accentColor, size: 14),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.redAccent.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
