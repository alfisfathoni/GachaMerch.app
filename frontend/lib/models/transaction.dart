class AppTransaction {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final double totalPrice;
  final String uid;
  final String server;
  final String status;
  final DateTime createdAt;
  final String productName;
  final String? productImage;

  AppTransaction({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.uid,
    required this.server,
    required this.status,
    required this.createdAt,
    required this.productName,
    this.productImage,
  });

  factory AppTransaction.fromJson(Map<String, dynamic> json) {
    return AppTransaction(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      totalPrice: double.parse(json['total_price'].toString()),
      uid: json['uid'],
      server: json['server'],
      status: json['status'] ?? 'SYNCHRONIZED',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      productName: json['product_name'] ?? 'Unknown Product',
      productImage: json['product_image'],
    );
  }
}
