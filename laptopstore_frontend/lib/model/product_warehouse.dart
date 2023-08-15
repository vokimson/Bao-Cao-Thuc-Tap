// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProductWarehouse {
  int productId;
  int? warehouseId;
  int quantity;
  ProductWarehouse({
    required this.productId,
    required this.warehouseId,
    required this.quantity,
  });

  factory ProductWarehouse.fromMap(Map<String, dynamic> map) {
    return ProductWarehouse(
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
      warehouseId: map['warehouse_id'] as int?,
    );
  }

  factory ProductWarehouse.fromJson(Map<String, dynamic> json) {
    return ProductWarehouse(
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      warehouseId: json['warehouse_id'] as int?,
    );
  }
}
