class OrderProduct {
  final int orderId;
  final int productId;
  final String productName;
  final double price;
  int quantity;
  final double taxRate;
  final String picture;

  OrderProduct({
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.taxRate,
    required this.picture,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      orderId: json['order_id'],
      productId: json['product_id'],
      productName: json['name'],
      price: double.parse(json['price'].toString()),
      quantity: int.parse(json['quantity'].toString()),
      taxRate: double.parse(json['tax_rate'].toString()),
      picture: json['picture'],
    );
  }
}
