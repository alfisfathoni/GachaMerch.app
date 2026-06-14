import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/product_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../widgets/cyber_loading.dart';
import 'wuthering_product_detail_page.dart';
import '../theme.dart';

class WutheringKatalogPage extends StatefulWidget {
  const WutheringKatalogPage({super.key});

  @override
  State<WutheringKatalogPage> createState() => _WutheringKatalogPageState();
}

class _WutheringKatalogPageState extends State<WutheringKatalogPage> {
  String _selectedCategory = 'all';

  Widget _buildProductImage(Product product, {required Color glowColor}) {
    return Image.asset(
      'assets/images/${product.imageUrl}',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.black.withOpacity(0.4),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: 28,
                color: glowColor.withOpacity(0.7),
              ),
              const SizedBox(height: 4),
              Text(
                'LOAD ERROR',
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: glowColor.withOpacity(0.7),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isFiveStar(Product product) {
    final name = product.name.toLowerCase();
    return name.contains('summit') ||
        name.contains('stringmaster') ||
        name.contains('genesis') ||
        name.contains('astrite');
  }

  IconData _getItemIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('broadblade') || lower.contains('summit')) return Icons.shield_rounded;
    if (lower.contains('rectifier') || lower.contains('stringmaster')) return Icons.ac_unit_rounded;
    if (lower.contains('sword') || lower.contains('emerald')) return Icons.colorize_rounded;
    if (lower.contains('echo:')) return Icons.radar_rounded;
    if (lower.contains('astrite')) return Icons.diamond_rounded;
    if (lower.contains('tide')) return Icons.stars_rounded;
    if (lower.contains('potion') || lower.contains('core')) return Icons.science_outlined;
    return Icons.token_outlined;
  }

  void _openDetail(BuildContext context, Product product) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, animation, secondaryAnimation) =>
            WutheringProductDetailPage(product: product),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
                  .animate(curved),
              child: child,
            ),
          );
        },
      ),
    ).then((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          // If the products are loading, display the cyber loading layout fullscreen
          if (productProvider.isLoading && productProvider.products.isEmpty) {
            return const Center(child: CyberLoading(label: 'CONNECTING SYSTEM...'));
          }

          if (productProvider.errorMessage.isNotEmpty && productProvider.products.isEmpty) {
            return _buildErrorState(productProvider);
          }

          final products = productProvider.products;
          final filteredProducts = _selectedCategory == 'all'
              ? products
              : products.where((p) => p.category == _selectedCategory).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Collapsing Parallax Header with Character Splash Art
              SliverAppBar(
                expandedHeight: 230.0,
                floating: false,
                pinned: true,
                stretch: true,
                backgroundColor: AppTheme.darkBg,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  title: Text(
                    'RESONANCE CONVENES',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Dark gradient background overlay
                      Image.network(
                        'https://wutheringwaves.kurogames.com/modules/website/assets/home/wallpaper/kv-3.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Parallax cyber-grid fallback gradient
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF0F1115), Color(0xFF020203)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          );
                        },
                      ),
                      // Glassmorphic siber grid lines decoration
                      CustomPaint(
                        painter: _GridLinesPainter(),
                      ),
                      // Shading overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.darkBg.withOpacity(0.95),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Featured Resonator Banner (Auto Scroll Carousel)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'FEATURED SIGNATURES',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor.withOpacity(0.85),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const FeaturedCarousel(),
                  ],
                ),
              ),

              // 3. Glassmorphic Category Tabs
              SliverToBoxAdapter(
                child: _buildCategoryTabs(),
              ),

              // 4. Products Grid with Rarity Glow borders
              filteredProducts.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No active products inside "${_selectedCategory.toUpperCase()}"',
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            color: Colors.grey[600],
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.64,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final product = filteredProducts[i];
                            final isFiveStar = _isFiveStar(product);
                            return GestureDetector(
                              onTap: () => _openDetail(context, product),
                              child: _buildProductCard(product, isFiveStar),
                            );
                          },
                          childCount: filteredProducts.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      {'id': 'all', 'label': 'ALL CONVENES'},
      {'id': 'Resonator Equipment', 'label': 'RESONATOR EQUIPMENT'},
      {'id': 'Supplies', 'label': 'SUPPLIES'},
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.containerBg.withOpacity(0.8) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: isSelected
                      ? Border.all(color: AppTheme.primaryColor.withOpacity(0.2))
                      : Border.all(color: Colors.transparent),
                ),
                child: Text(
                  cat['label']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[500],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isFiveStar) {
    // Determine glow color according to category: Gold (#FFD700) for Equipment, Cyan (#00D2C4) for Supplies
    final isEquipment = product.category == 'Resonator Equipment';
    final glowColor = isEquipment ? const Color(0xFFFFD700) : const Color(0xFF00D2C4);

    return Consumer<FavoritesProvider>(
      builder: (context, favProvider, _) {
        final isFav = favProvider.isFavorite(product.id);
        return GestureDetector(
          onTap: () => _openDetail(context, product),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: glowColor.withOpacity(isFiveStar ? 0.45 : 0.2),
                  width: isFiveStar ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(isFiveStar ? 0.12 : 0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Display Area with Hero tags
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: glowColor.withOpacity(0.04),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(painter: _CardMeshPainter(glowColor)),
                              ),
                              Center(
                                child: Hero(
                                  tag: 'product_icon_${product.id}',
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: _buildProductImage(product, glowColor: glowColor),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 10,
                                top: 10,
                                child: Text(
                                  product.category.toUpperCase(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.bold,
                                    color: glowColor.withOpacity(0.9),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              // Favorites toggle
                              Positioned(
                                right: 6,
                                top: 6,
                                child: GestureDetector(
                                  onTap: () => favProvider.toggleFavorite(product),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      size: 14,
                                      color: isFav ? Colors.redAccent : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(
                                isFiveStar ? 5 : 4,
                                (index) => Icon(
                                  Icons.star,
                                  size: 9,
                                  color: isFiveStar
                                      ? const Color(0xFFFFD700)
                                      : const Color(0xFFA33FF2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              product.description,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey[500],
                                fontSize: 9.5,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Rp ${product.price.toStringAsFixed(0)}',
                                    style: GoogleFonts.orbitron(
                                      color: glowColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: product.stock > 0
                                          ? glowColor.withOpacity(0.4)
                                          : Colors.red.withOpacity(0.4),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    product.stock > 0 ? 'x${product.stock}' : 'OUT',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 8.5,
                                      color: product.stock > 0
                                          ? glowColor
                                          : Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: ElevatedButton(
                                    onPressed: product.stock > 0 ? () async {
                                      final cartProvider = Provider.of<CartProvider>(context, listen: false);
                                      final success = await cartProvider.addToCart(product.id);
                                      if (success && context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppTheme.cardColor.withOpacity(0.95),
                                            content: Text(
                                              '${product.name} added to terminal storage!',
                                              style: GoogleFonts.orbitron(
                                                fontSize: 10,
                                                color: AppTheme.primaryColor,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            duration: const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(color: AppTheme.primaryColor, width: 1.0),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                        );
                                      }
                                    } : null,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: AppTheme.primaryColor,
                                      disabledBackgroundColor: Colors.grey.withOpacity(0.12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add_shopping_cart,
                                      size: 13,
                                      color: product.stock > 0 ? AppTheme.darkBg : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CustomPaint(
                      size: const Size(12, 12),
                      painter: _CornerCutPainter(glowColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),);
      },
    );
  }

  Widget _buildErrorState(ProductProvider productProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              'CONNECTION FAILED',
              style: GoogleFonts.orbitron(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.redAccent,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              productProvider.errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('RETRY'),
              onPressed: () => productProvider.fetchProducts(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Auto-scroll pageview featured banner ───────────────────────────────────
class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({super.key});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;
  late final Timer _timer;

  final List<Map<String, String>> _featuredItems = [
    {
      'title': 'VERDANT SUMMIT RATE-UP',
      'subtitle': 'Jiyan\'s signature 5★ Broadblade now available with enhanced pull chances.',
      'gradient': 'gold',
      'label': 'CONVENE TARGET',
    },
    {
      'title': 'ASTRITE GATE OVERLOAD',
      'subtitle': 'Get 3,240 Astrites + bonus convene tokens. Replenish your Convene reserves.',
      'gradient': 'cyan',
      'label': 'POPULAR DEAL',
    },
    {
      'title': 'SOUNDCONDUIT: YINLIN',
      'subtitle': 'Equip the Stringmaster 5★ Rectifier to fully tap into Electro synergy.',
      'gradient': 'purple',
      'label': 'EXCLUSIVE ITEM',
    }
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (idx) => setState(() => _currentPage = idx),
        itemCount: _featuredItems.length,
        itemBuilder: (context, idx) {
          final item = _featuredItems[idx];
          final isGold = item['gradient'] == 'gold';
          final isCyan = item['gradient'] == 'cyan';
          final primaryGradColor = isGold
              ? const Color(0xFFFFD700)
              : (isCyan ? const Color(0xFF00D2C4) : const Color(0xFFA33FF2));

          return Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryGradColor.withOpacity(0.35), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: primaryGradColor.withOpacity(0.08),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Immersive vector background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.cardColor,
                          primaryGradColor.withOpacity(0.12),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: GridPaper(
                        color: primaryGradColor,
                        interval: 15,
                        divisions: 1,
                        subdivisions: 1,
                      ),
                    ),
                  ),
                  // Banner information content
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: primaryGradColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: primaryGradColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            item['label']!,
                            style: GoogleFonts.orbitron(
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                              color: primaryGradColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['title']!,
                          style: GoogleFonts.orbitron(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            item['subtitle']!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              color: Colors.white70,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

// ── Collapsing Parallax Grid Lines ─────────────────────────────────────────
class _GridLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.08)
      ..strokeWidth = 1.0;

    // Drawing diagonal lines to project a high-end sci-fi background net
    for (int i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble() + 100, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerCutPainter extends CustomPainter {
  final Color color;
  _CornerCutPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardMeshPainter extends CustomPainter {
  final Color color;
  _CardMeshPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.08)
      ..strokeWidth = 0.8;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(
        Offset(0, size.height * 0.7), Offset(size.width * 0.8, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
