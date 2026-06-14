import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../theme.dart';
import 'cart_screen.dart';
import 'wuthering_checkout_page.dart';

class WutheringProductDetailPage extends StatefulWidget {
  final Product product;

  const WutheringProductDetailPage({super.key, required this.product});

  @override
  State<WutheringProductDetailPage> createState() =>
      _WutheringProductDetailPageState();
}

class _WutheringProductDetailPageState
    extends State<WutheringProductDetailPage>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  bool _isAddingToCart = false;
  late Product _product;

  // Scale animation for the CTA button
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _product = widget.product;

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnimation = _scaleController;

    // Fetch fresh data from backend
    _refreshProduct();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  /// Re-fetch latest stock & price from API
  Future<void> _refreshProduct() async {
    try {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final response = await provider.fetchProductById(_product.id);
      if (response != null && mounted) {
        setState(() {
          _product = response;
          // Clamp quantity if stale
          if (_quantity > _product.stock) {
            _quantity = _product.stock.clamp(1, _product.stock);
          }
        });
      }
    } catch (_) {
      // Keep existing product data on error
    }
  }

  Widget _buildProductImage(Product product, {required Color glowColor, double size = 100.0}) {
    return Image.asset(
      'assets/images/${product.imageUrl}',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: size * 0.4,
                color: glowColor.withOpacity(0.7),
              ),
              const SizedBox(height: 8),
              Text(
                'LOAD ERROR',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: glowColor.withOpacity(0.7),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _isFiveStar {
    final n = _product.name.toLowerCase();
    return n.contains('summit') ||
        n.contains('stringmaster') ||
        n.contains('genesis') ||
        n.contains('astrite');
  }

  Color get _glowColor =>
      _isFiveStar ? AppTheme.primaryColor : AppTheme.accentColor;

  String get _rarityTag => _isFiveStar
      ? '5★  RESONATOR EQUIPMENT'
      : (_product.category == 'Resonator Equipment'
          ? '4★  RESONATOR EQUIPMENT'
          : 'CRUCIAL SUPPLIES');

  IconData get _itemIcon {
    final lower = _product.name.toLowerCase();
    if (lower.contains('broadblade') || lower.contains('summit')) {
      return Icons.shield_rounded;
    } else if (lower.contains('rectifier') || lower.contains('stringmaster')) {
      return Icons.ac_unit_rounded;
    } else if (lower.contains('sword') || lower.contains('emerald')) {
      return Icons.colorize_rounded;
    } else if (lower.contains('echo')) {
      return Icons.radar_rounded;
    } else if (lower.contains('astrite')) {
      return Icons.diamond_rounded;
    } else if (lower.contains('tide')) {
      return Icons.stars_rounded;
    } else if (lower.contains('potion') || lower.contains('core')) {
      return Icons.science_outlined;
    }
    return Icons.token_outlined;
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void _incrementQty() {
    if (_quantity < _product.stock) setState(() => _quantity++);
  }

  void _decrementQty() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  Future<void> _addToCart() async {
    if (_product.stock == 0) return;

    await _scaleController.reverse();
    await _scaleController.forward();

    setState(() => _isAddingToCart = true);

    final cart = Provider.of<CartProvider>(context, listen: false);
    bool success = true;
    for (int i = 0; i < _quantity; i++) {
      final ok = await cart.addToCart(_product.id);
      if (!ok) { success = false; break; }
    }

    if (!mounted) return;
    setState(() => _isAddingToCart = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.cardColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: _glowColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: _glowColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_product.name} (x$_quantity) ADDED',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: AppTheme.primaryColor,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ),
      );
      await _refreshProduct();
    }
  }

  void _proceedToCheckout() {
    if (_product.stock == 0) return;
    _scaleController.reverse().then((_) => _scaleController.forward());

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WutheringCheckoutPage(
          product: _product,
          quantity: _quantity,
        ),
      ),
    ).then((_) {
      _refreshProduct();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final stockRatio =
        _product.stock > 0 ? (_product.stock / 100).clamp(0.0, 1.0) : 0.0;
    final isOutOfStock = _product.stock == 0;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // 1. Ambient Background paint
          Positioned(
            top: -60,
            left: MediaQuery.of(context).size.width / 2 - 120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _glowColor.withOpacity(0.05),
              ),
            ),
          ),

          // 2. Transparent Character Silhouette Overlay (Parallax vibe)
          Positioned(
            right: -60,
            top: 100,
            bottom: 200,
            child: Opacity(
              opacity: 0.07,
              child: Image.network(
                'https://images.squarespace-cdn.com/content/v1/660c6d311fa9cb56ff95b28a/3c6e9a66-de0d-40de-9b93-d2d79d71c2a1/Jinhsi_Wuthering_Waves.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox();
                },
              ),
            ),
          ),

          // Cyber siber gridlines in the background
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberBackgroundPainter(_glowColor),
            ),
          ),

          // 3. Main scroll content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroSection(),
                _buildInfoSection(stockRatio, isOutOfStock),
                const SizedBox(height: 140), // space for bottom bar
              ],
            ),
          ),

          // 4. Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(isOutOfStock),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final cartCount = Provider.of<CartProvider>(context).itemCount;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 15, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          color: AppTheme.accentColor, size: 18),
                    ),
                  ),
                ),
                if (cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$cartCount',
                          style: GoogleFonts.orbitron(
                              color: AppTheme.darkBg,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: 290,
      child: Stack(
        children: [
          // Gradient background for hero
          Container(
            height: 290,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _glowColor.withOpacity(0.06),
                  AppTheme.darkBg,
                ],
              ),
            ),
          ),
          // Glow ring
          Center(
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: _glowColor.withOpacity(0.12), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _glowColor.withOpacity(0.08),
                    blurRadius: 36,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          // Hero Product Icon
          Center(
            child: Hero(
              tag: 'product_icon_${_product.id}',
              child: _buildProductImage(_product, glowColor: _glowColor, size: 100.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(double stockRatio, bool isOutOfStock) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rarity tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _glowColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _glowColor.withOpacity(0.25), width: 1),
            ),
            child: Text(
              _rarityTag,
              style: GoogleFonts.orbitron(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: _glowColor,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Product name
          Text(
            _product.name,
            style: GoogleFonts.orbitron(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 18),

          // Price & Stock row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SHELL CREDITS',
                      style: GoogleFonts.orbitron(
                        fontSize: 8.5,
                        color: Colors.white.withOpacity(0.4),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.monetization_on_outlined,
                            color: AppTheme.primaryColor, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Rp ${_product.price.toStringAsFixed(0)}',
                          style: GoogleFonts.orbitron(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryColor,
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
                    isOutOfStock ? 'OUT OF STOCK' : 'STOCK: ${_product.stock}',
                    style: GoogleFonts.orbitron(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock ? Colors.redAccent : Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 100,
                      height: 4,
                      child: LinearProgressIndicator(
                        value: stockRatio,
                        backgroundColor: AppTheme.borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOutOfStock
                              ? Colors.redAccent
                              : (stockRatio > 0.4
                                  ? AppTheme.accentColor
                                  : AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Glassmorphic Description box
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 3, height: 12, color: _glowColor),
                        const SizedBox(width: 8),
                        Text(
                          'ITEM DESCRIPTION',
                          style: GoogleFonts.orbitron(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _product.description.isNotEmpty
                          ? _product.description
                          : 'No description available for this item.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: Colors.grey[400],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 5. Siber Echo Upgrade Stats Table
          _buildSiberStatsTable(),
          const SizedBox(height: 24),

          if (!isOutOfStock) _buildQuantitySelector(),
        ],
      ),
    );
  }

  Widget _buildSiberStatsTable() {
    // Determine stats values mock based on rarity or category
    final isEquip = _product.category == 'Resonator Equipment';
    final stat1 = isEquip ? 'RESONANCE ATK' : 'WAVE ENERGY';
    final stat1Val = isEquip ? '+420 ATK' : '+60 Waveplates';
    final stat2 = isEquip ? 'CRIT RATIO' : 'CONVENE VALUE';
    final stat2Val = isEquip ? '+8.4%' : 'High-Conduit';
    final stat3 = isEquip ? 'ENERGY REGEN' : 'PURIFICATION';
    final stat3Val = isEquip ? '+15.4%' : 'Immediate';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _glowColor.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt, color: _glowColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  'CONDUIT SYNCHRONIZATION STATS',
                  style: GoogleFonts.orbitron(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: _glowColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildStatRow(Icons.offline_bolt_outlined, stat1, stat1Val),
            const Divider(color: Colors.white10),
            _buildStatRow(Icons.radar_outlined, stat2, stat2Val),
            const Divider(color: Colors.white10),
            _buildStatRow(Icons.flash_on_outlined, stat3, stat3Val),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 9,
              color: Colors.grey[400],
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: _glowColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUANTITY',
          style: GoogleFonts.orbitron(
            fontSize: 8.5,
            color: Colors.white.withOpacity(0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _QtyButton(
              icon: Icons.remove,
              onTap: _decrementQty,
              enabled: _quantity > 1,
              color: _glowColor,
            ),
            const SizedBox(width: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                '$_quantity',
                key: ValueKey(_quantity),
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            _QtyButton(
              icon: Icons.add,
              onTap: _incrementQty,
              enabled: _quantity < _product.stock,
              color: _glowColor,
            ),
            const SizedBox(width: 20),
            Text(
              'MAX AVAILABLE: ${_product.stock}',
              style: GoogleFonts.orbitron(
                fontSize: 8.5,
                color: Colors.white.withOpacity(0.25),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(bool isOutOfStock) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(context).padding.bottom + 14,
          ),
          decoration: BoxDecoration(
            color: AppTheme.darkBg.withOpacity(0.85),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PAY',
                      style: GoogleFonts.orbitron(
                        fontSize: 8.5,
                        color: Colors.white.withOpacity(0.35),
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Rp ${(_product.price * _quantity).toStringAsFixed(0)}',
                      style: GoogleFonts.orbitron(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.5,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTap: isOutOfStock ? null : _proceedToCheckout,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    width: 190,
                    decoration: BoxDecoration(
                      gradient: isOutOfStock
                          ? null
                          : LinearGradient(
                              colors: _isFiveStar
                                  ? [AppTheme.primaryColor, const Color(0xFFE8C26E)]
                                  : [AppTheme.accentColor, const Color(0xFF00A89C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: isOutOfStock ? AppTheme.borderColor : null,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isOutOfStock
                          ? []
                          : [
                              BoxShadow(
                                color: _glowColor.withOpacity(0.35),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        isOutOfStock ? 'OUT OF STOCK' : 'CONFIRM PURCHASE',
                        style: GoogleFonts.orbitron(
                          color: AppTheme.darkBg,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
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

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final Color color;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? color.withOpacity(0.35) : AppTheme.borderColor,
            width: 1.2,
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color: enabled ? color : Colors.grey[700],
        ),
      ),
    );
  }
}

class _CyberBackgroundPainter extends CustomPainter {
  final Color color;
  _CyberBackgroundPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.04)
      ..strokeWidth = 1.0;

    // Draw some horizontal and diagonal grid HUD elements
    for (double i = 0; i < size.height * 0.8; i += 60) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i + 20), paint);
    }

    final hudPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw decorative HUD circle in bottom left background area
    canvas.drawCircle(Offset(40, size.height * 0.7), 80, hudPaint);
    canvas.drawCircle(Offset(40, size.height * 0.7), 88, hudPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
