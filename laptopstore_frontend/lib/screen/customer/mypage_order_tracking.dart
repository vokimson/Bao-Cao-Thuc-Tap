// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:storelaptop/screen/customer/infoOrderTracking.dart';
import '../../model/order.dart';

class OrderTracking extends StatefulWidget {
  int userId;
  OrderTracking({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<OrderTracking> createState() => _OrderTrackingState();
}

class _OrderTrackingState extends State<OrderTracking> {
  int userId = 0;
  List<Order> orders = [];
  int selectedButtonIndex = 0;
  int totalQuantity = 0;
  double totalPrice = 0;
  String selectTab = '';

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    awaitfetchGetOrderOfUserWithStatus(userId, 'placed');
    selectTab = 'placed';
  }

  Future<void> awaitfetchGetOrderOfUserWithStatus(
      int userId, String status) async {
    List<Order> temp = await fetchGetOrderOfUserWithStatus(userId, status);
    setState(() {
      orders = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Theo dõi đơn hàng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ButtonMethod(0, 'Đóng gói', () async {
                      await awaitfetchGetOrderOfUserWithStatus(
                          userId, 'placed');
                      selectTab = 'placed';
                      setState(() {
                        selectedButtonIndex = 0;
                      });
                    }),
                    ButtonMethod(1, 'Đang giao', () async {
                      await awaitfetchGetOrderOfUserWithStatus(
                          userId, 'delivering');
                      selectTab = 'delivering';
                      setState(() {
                        selectedButtonIndex = 1;
                      });
                    }),
                    ButtonMethod(2, 'Hủy đơn', () async {
                      await awaitfetchGetOrderOfUserWithStatus(
                          userId, 'cancel');
                      selectTab = 'cancel';
                      setState(() {
                        selectedButtonIndex = 2;
                      });
                    }),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: orders.map((order) {
                      // DateTime date = DateTime.parse(order.orderDate!);

                      // DateTime newDate = date.add(const Duration(days: 1));

                      // String formattedNewDate =
                      //     DateFormat('yyyy-MM-dd').format(newDate);
                      // order.orderDate = formattedNewDate;
                      return OrderBody(
                          order.orderId,
                          order.orderDate ?? ' ',
                          order.totalQuantity ?? 0,
                          order.totalPrice ?? 0,
                          order.status ?? ' ',
                          order,
                          selectedButtonIndex);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container OrderBody(int orderId, String datetime, int quantity, double price,
      String status, Order order, int? tab) {
    return Container(
      width: double.infinity,
      height: 165,
      margin: const EdgeInsets.only(top: 10),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 25,
            offset: Offset(0, 1),
            spreadRadius: 0,
          )
        ],
      ),
      child: Stack(children: [
        Positioned(
            left: 20,
            top: 10,
            child: Text(
              'Mã đơn: ' '$orderId',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )),
        const Positioned(
            left: 20,
            top: 44,
            child: Opacity(
              opacity: 0.5,
              child: Text(
                'Số lượng:',
                style: TextStyle(fontSize: 17),
              ),
            )),
        const Positioned(
            left: 20,
            top: 74,
            child: Opacity(
              opacity: 0.5,
              child: Text(
                'Tổng cộng:',
                style: TextStyle(fontSize: 17),
              ),
            )),
        Positioned(
            right: 20,
            top: 14,
            child: Opacity(
              opacity: 0.5,
              child: Text(
                datetime.substring(0, 10),
                style: const TextStyle(
                  fontSize: 19,
                ),
              ),
            )),
        Positioned(
            right: 20,
            top: 44,
            child: Text(
              '$quantity',
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            )),
        Positioned(
          right: 20,
          top: 74,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: NumberFormat.decimalPattern().format(price).toString(),
                  style: const TextStyle(
                    color: Color(0xFFFFA013),
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
                const TextSpan(
                  text: ' ₫',
                  style: TextStyle(
                    color: Color(0xFFFFA013),
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            right: 110,
            left: 110,
            top: 104,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      // side: const BorderSide(color: Colors.black)
                    ),
                    backgroundColor: const Color(0xFFFFA013),
                    minimumSize: const Size(50, 40)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return InfoOrderTracking(
                        order: order,
                        tab: tab ?? 0,
                      );
                    }),
                  ).then((value) {
                    setState(() {
                      awaitfetchGetOrderOfUserWithStatus(userId, selectTab);
                    });
                  });
                },
                child: const Text(
                  'Xem chi tiết',
                  style: TextStyle(fontSize: 18),
                ))),
      ]),
    );
  }

  ElevatedButton ButtonMethod(
      int buttonIndex, String buttonText, VoidCallback onClick) {
    return ElevatedButton(
      onPressed: onClick,
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: selectedButtonIndex == buttonIndex
              ? const Color(0xFFFFA013)
              : Colors.black,
          minimumSize: const Size(120, 45)),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

Future<List<Order>> fetchGetOrderOfUserWithStatus(
    int userId, String status) async {
  final url =
      Uri.parse('http://10.0.2.2:8080/api/v1/order/getOrderOfUserWithStatus');
  final apiUrlWithParams = url.replace(queryParameters: {
    if (userId != null) 'user_id': userId.toString(),
    if (status != null) 'status': status,
  });
  try {
    final response = await http.get(apiUrlWithParams);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['body'] != null &&
          data['body'] is List &&
          data['body'].isNotEmpty) {
        final List<dynamic> bodyData = data['body'][0];
        List<Order> orders =
            bodyData.map((json) => Order.fromMap(json)).toList();
        return orders;
      } else {
        print('Data not found');
      }
    } else {
      print('Lỗi fetchGetOrderOfUserWithStatus');
      print(response.statusCode);
    }
  } catch (e) {
    print('Lỗi fetchGetOrderOfUserWithStatus');
    print('Error: $e');
  }
  return [];
}
