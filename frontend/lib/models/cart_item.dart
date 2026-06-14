class CartItem {
  final int id; // The ID of the cart entry
  final int productId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      stock: json['stock'],
      imageUrl: json['image_url'],
      quantity: json['quantity'],
    );
  }
}
