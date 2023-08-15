// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:intl/intl.dart';

class User {
  final int userId;
  String? email;
  String password;
  String fullName;
  String? dateOfBirth;
  String phone;
  String? address;
  int? customerId;
  User({
    required this.userId,
    required this.email,
    required this.password,
    required this.fullName,
    required this.dateOfBirth,
    required this.phone,
    required this.address,
    required this.customerId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // String dateOfBirth = formatDate(json, 'date_of_birth');
    return User(
      userId: json['user_id'],
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      fullName: json['full_name'],
      // dateOfBirth: json['date_of_birth'] ?? '',
      dateOfBirth: formatDate(json, 'date_of_birth'),
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      customerId: json['customer_id'] ?? 0,
    );
  }
}

String formatDate(Map<String, dynamic> json, String dateK) {
  if (json[dateK] != null) {
    DateTime date = DateTime.parse(json[dateK]);
    DateTime newDate = date.add(const Duration(days: 1));
    String formattedNewDate =
        DateFormat('yyyy-MM-dd').format(newDate).substring(0, 10);
    return formattedNewDate;
  } else {
    return '';
  }
}
