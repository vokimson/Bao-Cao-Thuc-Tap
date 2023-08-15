import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storelaptop/screen/customer/dataShare.dart';

import '../../model/order.dart';
import 'infoOrderTracking.dart';
import 'mypage_order_tracking.dart';

class HistoryOrder extends StatefulWidget {
  const HistoryOrder({super.key});

  @override
  State<HistoryOrder> createState() => _HistoryOrderState();
}

class _HistoryOrderState extends State<HistoryOrder> {
  int userId = 0;
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    awaitData();
  }

  Future<void> awaitData() async {
    int userId = Provider.of<DataShare>(context, listen: false).userId;
    print(userId);
    List<Order> temp = await fetchGetOrderOfUserWithStatus(userId, 'delivered');
    setState(() {
      orders = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    int userId = Provider.of<DataShare>(context, listen: false).userId;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Lịch sử mua hàng',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Danh sách đơn hàng',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Column(
                children: orders.map((order) {
                  return OrderBody(
                    order.orderId,
                    order.orderDate ?? ' ',
                    order.totalQuantity ?? 0,
                    order.totalPrice ?? 0,
                    order.status ?? ' ',
                    order,
                    3,
                  );
                }).toList(),
              ),
            ],
          ),
        ));
  }

  Container OrderBody(int orderId, String datetime, int quantity, double price,
      String status, Order order, int tab) {
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
                        tab: tab,
                      );
                    }),
                  );
                },
                child: const Text(
                  'Xem chi tiết',
                  style: TextStyle(fontSize: 18),
                ))),
      ]),
    );
  }
}
