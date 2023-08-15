// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProductPrice {
  final int productId;
  double price;
  ProductPrice({
    required this.productId,
    required this.price,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    final productId = json['product_id'];
    final price = json['price'].toDouble();
    return ProductPrice(productId: productId, price: price);
  }
}
