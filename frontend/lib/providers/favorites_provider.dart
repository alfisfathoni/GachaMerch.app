import 'package:flutter/material.dart';
import '../models/product.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Product> _favorites = [];

  List<Product> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(int productId) {
    return _favorites.any((p) => p.id == productId);
  }

  void toggleFavorite(Product product) {
    final index = _favorites.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }

  void removeFavorite(int productId) {
    _favorites.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
}
