// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storelaptop/screen/customer/InfoProduct.dart';

import 'package:storelaptop/screen/customer/dataShare.dart';
import 'package:storelaptop/screen/customer/order_success.dart';

import '../../model/order_product.dart';
import '../../model/user.dart';

class Payment extends StatefulWidget {
  final int user_id;
  final int order_id;
  final double total;
  List<OrderProduct> carts;
  Payment({
    Key? key,
    required this.user_id,
    required this.order_id,
    required this.total,
    required this.carts,
  }) : super(key: key);

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  late User user;
  List<OrderProduct> carts = [];
  TextEditingController addressController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  int selectedPaymentMethod = 1;
  int user_id = 0;
  int order_id = 0;
  double total = 0;
  int pay_id = 1;
  String errorMessage = '';

  String address = '';
  String description = '';

  @override
  void initState() {
    super.initState();
    user_id = widget.user_id;
    order_id = widget.order_id;
    carts = widget.carts;
    total = widget.total;

    loadAddress(user_id);

    // print('user_id pay :${user.userId}');
  }

  void loadAddress(int userId) async {
    await fetchUserInfo(userId);
    setState(() {
      addressController.text = address;
    });
  }

  void selectPaymentMethod(int method) {
    setState(() {
      selectedPaymentMethod = method;
      pay_id = method;
    });
  }

  Future<void> fetchUserInfo(int userId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/user/getInfoUserById');
    final apiUrlWithParams =
        url.replace(queryParameters: {'user_id': userId.toString()});
    try {
      final response = await http.get(apiUrlWithParams);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'] != null) {
          address = data['body'][0]['address'] ?? '';
        }
      }
    } catch (e) {
      print('Lỗi fetchUserInfo');
      print('Error: $e');
    }
  }

  Future<bool> fetchUpdatePayOrDer(
      int payId, String description, String address, int orderId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/order/updatePayOrder');

    try {
      final response = await http.put(url, body: {
        'pay_id': payId.toString(),
        'description': description,
        'address': address,
        'order_id': orderId.toString(),
        'shopping_area':
            Provider.of<DataShare>(context, listen: false).selectArea,
      });
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Lỗi fetchUpdatePayOrDer');
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Lỗi fetchUpdatePayOrDer');
      print('Error: $e');
      return false;
    }
  }

  Future<bool> fetchUpdateOrderConfirm(
      int productId, int quantity, String shoppingArea) async {
    final url =
        Uri.parse('http://10.0.2.2:8080/api/v1/order/updateOrderConfirm');
    try {
      final response = await http.put(url, body: {
        'product_id': productId.toString(),
        'quantity': quantity.toString(),
        'shopping_area': shoppingArea,
      });
      if (response.statusCode == 200) {
        print('object11');
        return true;
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi fetchUpdateOrderConfirm');
      print('Error: $e');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Thanh toán',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 18, bottom: 10, right: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Địa chỉ nhận hàng',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    // onChanged: (value) => {textValue = value},
                    controller: addressController,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintText: 'Nhập địa chỉ',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    child: errorMessage.isNotEmpty
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 15),
                            ),
                          )
                        : const SizedBox(),
                  ),
                  const Text(
                    'Phương thức thanh toán',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    leading: Checkbox(
                      value: selectedPaymentMethod == 1,
                      onChanged: (value) {
                        selectPaymentMethod(1);
                      },
                      activeColor: Colors.amber,
                    ),
                    title: const Text(
                      'Thanh toán khi nhận hàng',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListTile(
                    leading: Checkbox(
                      value: selectedPaymentMethod == 2,
                      onChanged: (value) {
                        selectPaymentMethod(2);
                      },
                      activeColor: Colors.amber,
                    ),
                    title: const Text(
                      'Thẻ tín dụng',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ListTile(
                    leading: Checkbox(
                      value: selectedPaymentMethod == 3,
                      onChanged: (value) {
                        selectPaymentMethod(3);
                      },
                      activeColor: Colors.amber,
                    ),
                    title: const Text(
                      'Ví điện tử',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Ghi chú',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    child: SizedBox(
                      height: 110,
                      child: TextField(
                        // onChanged: (value) => {textValue = value},
                        controller: noteController,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 16),
                          hintText: 'Thông tin thêm\n\n\n',
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        onChanged: (value) {
                          setState(() {
                            description = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng:',
                        style: TextStyle(
                            fontSize: 22,
                            color: Color(0xFFFFA013),
                            fontWeight: FontWeight.bold),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: NumberFormat.decimalPattern()
                                  .format(total)
                                  .toString(),
                              style: const TextStyle(
                                color: Color(0xFFFFA013),
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const TextSpan(
                              text: ' ₫',
                              style: TextStyle(
                                color: Color(0xFFFFA013),
                                fontSize: 24,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFFFFA013)),
                      minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 50)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      address = addressController.text;
                      if (address == '') {
                        setState(() {
                          errorMessage = 'Bạn chưa nhập địa chỉ giao hàng';
                        });
                      } else {
                        if (await fetchUpdatePayOrDer(
                            pay_id, description, address, order_id)) {
                          String area =
                              Provider.of<DataShare>(context, listen: false)
                                  .selectArea;
                          bool check = true;
                          for (OrderProduct cart in carts) {
                            await fetchUpdateOrderConfirm(
                                cart.productId, cart.quantity, area);
                            // if (check == false) break;
                          }
                          // if (check == true) {
                          Provider.of<DataShare>(context, listen: false)
                              .setCartItemCount(0);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    OrderSuccess(user_id: user_id)),
                          );
                          // }
                        } else {
                          showShortSnackBar(
                              context, 'Đã xảy ra lỗi vui lòng thử lại sau!');
                        }
                      }
                    },
                    child: const Text(
                      'Đặt hàng',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
