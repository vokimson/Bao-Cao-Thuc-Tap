// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storelaptop/screen/customer/InfoProduct.dart';

import '../../model/order.dart';
import '../../model/order_product.dart';
import 'dataShare.dart';

class InfoOrderTracking extends StatefulWidget {
  Order order;
  int tab;
  InfoOrderTracking({
    Key? key,
    required this.order,
    required this.tab,
  }) : super(key: key);

  @override
  State<InfoOrderTracking> createState() => _InfoOrderTrackingState();
}

class _InfoOrderTrackingState extends State<InfoOrderTracking> {
  late Order order;
  int tab = 0;
  List<OrderProduct> orderDetails = [];
  String payName = '';

  @override
  void initState() {
    super.initState();
    order = widget.order;
    tab = widget.tab;
    awaitfetchDetailOrderById();
  }

  Future<void> awaitfetchDetailOrderById() async {
    await fetchDetailOrderById(order.orderId);
    print(order.pay_id);
    await fetchPayNameById(order.pay_id);
  }

  Future<void> fetchDetailOrderById(int orderId) async {
    final url =
        Uri.parse('http://10.0.2.2:8080/api/v1/order/getDetailOrderById');
    final apiUrlWithParams =
        url.replace(queryParameters: {'order_id': orderId.toString()});
    try {
      final response = await http.get(apiUrlWithParams);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'] != null) {
          final List<dynamic> bodyData = data['body'];
          // order_id = int.parse(data['body']['order_id']);
          setState(() {
            orderDetails =
                bodyData.map((json) => OrderProduct.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      print('Lỗi fetchDetailOrderById');
      print('Error: $e');
    }
  }

  Future<void> fetchPayNameById(int payId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/order/getPayNameById');
    final apiUrlWithParams =
        url.replace(queryParameters: {'pay_id': payId.toString()});
    try {
      final response = await http.get(apiUrlWithParams);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'] != null) {
          setState(() {
            payName = data['body'][0]['pay_name'];
          });
        }
      }
    } catch (e) {
      print('Lỗi fetchPayNameById');
      print('Error: $e');
    }
  }

  Future<bool> fetchUpdateCancelOrder(
      int orderId, int productId, int quantity) async {
    final url =
        Uri.parse('http://10.0.2.2:8080/api/v1/order/updateCancelOrder');
    try {
      final response = await http.put(url, body: {
        'product_id': productId.toString(),
        'order_id': orderId.toString(),
        'quantity': quantity.toString(),
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Lỗi fetchUpdateCancelOrder');
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi fetchUpdateCancelOrder');
      print('Error: $e');
    }
    return false;
  }

  Future<bool> fetchUpdateStatusOrder(
      int userId, int orderId, String status) async {
    final url =
        Uri.parse('http://10.0.2.2:8080/api/v1/order/updateOrderStatus');
    try {
      final response = await http.put(url, body: {
        'user_id': userId.toString(),
        'order_id': orderId.toString(),
        'status': status,
      });

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Lỗi fetchUpdateStatusOrder');
      print('Error: $e');
    }
    return false;
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
          'Chi tiết đơn hàng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mã đơn: ${order.orderId}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Opacity(
                        opacity: 0.5,
                        child: Text(
                          order.orderDate.toString().substring(0, 10),
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${order.totalQuantity} sản phẩm',
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                  SizedBox(
                    height: 305,
                    child: SingleChildScrollView(
                      child: Column(
                        children: orderDetails.map((detailOrder) {
                          return OrderDetailBody(
                            detailOrder,
                            detailOrder.picture,
                            detailOrder.productName,
                            detailOrder.quantity,
                            detailOrder.price,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin đơn hàng',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      InfoBody('Địa chỉ nhận hàng:', order.address!),
                      InfoBody('Phương thức thanh toán:', payName),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 9, top: 7, bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Tổng tiền:',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 9),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: NumberFormat.decimalPattern()
                                          .format(order.totalPrice)
                                          .toString(),
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
                          ],
                        ),
                      ),
                      if (tab != 2 && tab != 3)
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xFFFFA013)),
                            minimumSize: MaterialStateProperty.all(
                                const Size(double.infinity, 50)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Xác nhận hủy đơn'),
                                  content: const Text(
                                      'Bạn có chắc chắn muốn hủy đơn này?'),
                                  actions: <Widget>[
                                    // Nút Hủy
                                    TextButton(
                                      child: const Text('Hủy'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    // Nút Xác nhận hủy đơn
                                    TextButton(
                                      child: const Text('Xác nhận'),
                                      onPressed: () async {
                                        if (await fetchUpdateStatusOrder(
                                            userId, order.orderId, 'cancel')) {
                                          for (OrderProduct detail
                                              in orderDetails) {
                                            await fetchUpdateCancelOrder(
                                                detail.orderId,
                                                detail.productId,
                                                detail.quantity);
                                          }
                                        }
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        showShortSnackBar(context,
                                            'Đã hủy đơn hàng thành công!');
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text(
                            'Hủy đơn',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      if (tab == 2)
                        Column(
                          children: [
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Đã hủy đơn hàng',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                order.updatedDate.toString().substring(0, 10),
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      if (tab == 3)
                        Column(
                          children: [
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Đã hoàn tất giao hàng',
                                style: TextStyle(
                                    color: Colors.green, fontSize: 20),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                order.deliveredDate.toString().substring(0, 10),
                                style: const TextStyle(
                                    color: Colors.green, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Container OrderDetailBody(OrderProduct cartUser, String picture, String name,
    int quantity, double price) {
  return Container(
    width: double.infinity,
    height: 100,
    margin: const EdgeInsets.only(top: 10),
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
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
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Image.network(
              picture,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // const SizedBox(width: 10),
        Positioned(
            // top: 5,
            left: 110,
            child: Container(
                width: 210,
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(top: 15),
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18),
                ))),
        Positioned(
            // top: 5,
            right: 20,
            bottom: 17,
            child: Container(
                width: 190,
                alignment: Alignment.centerRight,
                // margin: const EdgeInsets.only(top: 15),
                child: Text(
                  'Số lượng: $quantity',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ))),
      ],
    ),
  );
}

Padding InfoBody(String left, String right) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(left,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 17,
                      )),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 230),
                    child: Text(
                      right,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    ),
  );
}
