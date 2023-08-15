// ignore_for_file: public_member_api_docs, sort_constructors_first

class Order {
  final int orderId;
  final String? description;
  String? address;
  final String? status;
  String? orderDate;
  final String? deliveredDate;
  String? updatedDate;
  int? updateUser;
  double totalAmount;
  double taxAmount;
  final int pay_id;
  final int user_id;
  final int totalQuantity;
  final double totalPrice;

  Order({
    required this.orderId,
    required this.description,
    this.address,
    required this.status,
    required this.orderDate,
    required this.deliveredDate,
    required this.updatedDate,
    this.updateUser,
    required this.totalAmount,
    required this.taxAmount,
    required this.pay_id,
    required this.user_id,
    required this.totalQuantity,
    required this.totalPrice,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    // String? deliveredDate = formatDate(map, 'delivered_date');
    // String? orderDate = formatDate(map, 'order_date');

    return Order(
      orderId: map['order_id'] ?? 0,
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      status: map['status'] ?? '',
      // orderDate: map['order_date'] ?? '',
      orderDate: map['order_date'] ?? '',
      // deliveredDate: map['delivered_date'] ?? '',
      deliveredDate: map['delivered_date'] ?? '',
      updatedDate: map['updated_date'] ?? '',
      updateUser: map['update_user'],
      totalAmount: map['total_amount'] ?? 0,
      taxAmount: map['tax_amount'] ?? 0,
      pay_id: map['pay_id'] ?? 0,
      user_id: map['user_id'] ?? 0,
      totalQuantity: map['total_quantity'] != null
          ? int.parse(map['total_quantity'].toString())
          : 0,
      totalPrice: map['total_price'] != null
          ? double.parse(map['total_price'].toString())
          : 0,
    );
  }
}
