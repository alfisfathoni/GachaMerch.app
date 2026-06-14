import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/favorites_provider.dart';
import '../models/product.dart';
import 'wuthering_product_detail_page.dart';
import '../theme.dart';

class WutheringFavoritesPage extends StatelessWidget {
  const WutheringFavoritesPage({super.key});

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
    if (lower.contains('astrite')) return Icons.diamond_rounded;
    if (lower.contains('tide')) return Icons.stars_rounded;
    return Icons.token_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favProvider, _) {
        final favorites = favProvider.favorites;

        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.6),
                      AppTheme.accentColor.withOpacity(0.3),
                    ],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'NO FAVORITES YET',
                  style: GoogleFonts.orbitron(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.white70,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the ♡ on any item in ECHOES\nto add it to your collection.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey[600],
                    height: 1.6,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: favorites.length,
          itemBuilder: (ctx, i) {
            final product = favorites[i];
            final isFiveStar = _isFiveStar(product);
            final glowColor = isFiveStar ? AppTheme.primaryColor : AppTheme.accentColor;
            return GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WutheringProductDetailPage(product: product),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: glowColor.withOpacity(isFiveStar ? 0.45 : 0.2), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withOpacity(isFiveStar ? 0.12 : 0.05),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon area with Hero
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: glowColor.withOpacity(0.04),
                            child: Stack(
                              children: [
                                Center(
                                  child: Hero(
                                    tag: 'product_icon_${product.id}',
                                    child: Icon(
                                      _getItemIcon(product.name),
                                      size: 46,
                                      color: glowColor.withOpacity(0.85),
                                    ),
                                  ),
                                ),
                                // Remove from favorites
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: GestureDetector(
                                    onTap: () => favProvider.removeFavorite(product.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.favorite,
                                        size: 14,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Info
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              const SizedBox(height: 4),
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
                                  Text(
                                    'Stock: ${product.stock}',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 8.5,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: glowColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: glowColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  'VIEW ITEM',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 8,
                                    color: glowColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
