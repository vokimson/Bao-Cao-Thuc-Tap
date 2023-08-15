import 'package:intl/intl.dart';
import 'package:storelaptop/model/user.dart';

class Customer extends User {
  String? tax_code;
  String shopping_area;
  int first_login;

  Customer({
    required int userId,
    required String? email,
    required String password,
    required String fullName,
    required String? dateOfBirth,
    required String phone,
    required String? address,
    required int? customerId,
    this.tax_code,
    required this.shopping_area,
    required this.first_login,
  }) : super(
          userId: userId,
          email: email,
          password: password,
          fullName: fullName,
          dateOfBirth: dateOfBirth,
          phone: phone,
          address: address,
          customerId: customerId,
        );

  factory Customer.fromJson(Map<String, dynamic> json) {
    String dateOfBirth = formatDate(json, 'date_of_birth');
    return Customer(
      userId: json['user_id'] ?? 0,
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      fullName: json['full_name'] ?? '',
      dateOfBirth: dateOfBirth ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      customerId: json['customer_id'] ?? 0,
      tax_code: json['tax_code'] ?? '',
      shopping_area: json['shopping_area'] ?? '',
      first_login: json['first_login'] ?? 0,
    );
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    String dateOfBirth = formatDate(map, 'date_of_birth');
    return Customer(
      userId: map['user_id'] ?? 0,
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      fullName: map['full_name'] ?? '',
      dateOfBirth: dateOfBirth ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      customerId: map['customer_id'] ?? 0,
      tax_code: map['tax_code'] ?? '',
      shopping_area: map['shopping_area'] ?? '',
      first_login: map['first_login'] ?? 0,
    );
  }
}

String formatDate(Map<String, dynamic> json, String dateK) {
  if (json.containsKey(dateK) && json[dateK] != null && json[dateK] is String) {
    DateTime date = DateTime.parse(json[dateK]);
    DateTime newDate = date.add(const Duration(days: 1));
    String formattedNewDate = DateFormat('yyyy-MM-dd').format(newDate);
    return formattedNewDate;
  }
  return '';
}
