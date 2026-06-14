import 'package:flutter_test/flutter_test.dart';
import 'package:gachamerch/models/product.dart';

void main() {
  test('Product.fromJson parses correctly', () {
    final json = {
      'id': 1,
      'name': 'Verdant Summit',
      'description': 'A legendary 5★ broadblade.',
      'price': 648000.00,
      'stock': 10,
      'image_url': 'verdant_summit',
      'category': 'equipment'
    };

    final product = Product.fromJson(json);

    expect(product.id, 1);
    expect(product.name, 'Verdant Summit');
    expect(product.description, 'A legendary 5★ broadblade.');
    expect(product.price, 648000.00);
    expect(product.stock, 10);
    expect(product.imageUrl, 'verdant_summit');
    expect(product.category, 'equipment');
  });
}
