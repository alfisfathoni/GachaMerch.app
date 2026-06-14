class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      stock: json['stock'],
      imageUrl: json['image_url'],
      category: json['category'] ?? 'Supplies',
    );
  }
}
