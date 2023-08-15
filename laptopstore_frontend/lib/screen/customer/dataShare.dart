import 'package:flutter/material.dart';

import '../../model/customer.dart';

class DataShare extends ChangeNotifier {
  int _cartItemCount = 0;
  List<String> _areas = []; // danh sách khu vực mở bán
  String _selectArea = ''; // khu vực mua sắm của khách hàng
  int _userId = 0;
  Customer _customer = Customer(
      userId: 0,
      email: '',
      password: '',
      fullName: '',
      dateOfBirth: '',
      phone: '',
      address: '',
      customerId: 0,
      tax_code: '',
      shopping_area: '',
      first_login: 0);

  int get cartItemCount => _cartItemCount;
  int get userId => _userId;
  List<String> get areas => _areas;
  String get selectArea => _selectArea;

  void addToCart([int quantity = 1]) {
    _cartItemCount += quantity;
    notifyListeners();
  }

  void subToCart([int quantity = 1]) {
    _cartItemCount -= quantity;
    notifyListeners();
  }

  void setCartItemCount(int newValue) {
    _cartItemCount = newValue;
    notifyListeners();
  }

  void setAreas(List<String> newAreas) {
    _areas = newAreas;
    notifyListeners();
  }

  void setSelectArea(String newArea) {
    _selectArea = newArea;
    notifyListeners();
  }

  void setUserId(int userId) {
    _userId = userId;
    notifyListeners();
  }


}
