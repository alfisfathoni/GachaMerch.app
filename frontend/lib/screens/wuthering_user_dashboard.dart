import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'home_screen.dart';

/// WutheringUserDashboard wraps the existing HomeScreen storefront
/// so regular users land here after login — and any product changes made
/// by admin (via ProductProvider.notifyListeners) are reflected instantly.
class WutheringUserDashboard extends StatefulWidget {
  const WutheringUserDashboard({super.key});

  @override
  State<WutheringUserDashboard> createState() => _WutheringUserDashboardState();
}

class _WutheringUserDashboardState extends State<WutheringUserDashboard> {
  @override
  void initState() {
    super.initState();
    // Ensure user always gets the latest product list on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }


  @override
  Widget build(BuildContext context) {
    // HomeScreen already contains the full shop UI with product grid,
    // cart, and category filters. We render it directly.
    return const HomeScreen();
  }
}
