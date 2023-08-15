import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storelaptop/model/product_price.dart';
import 'package:http/http.dart' as http;
import 'package:storelaptop/screen/customer/InfoProduct.dart';
import 'package:storelaptop/screen/customer/dataShare.dart';
import 'package:storelaptop/screen/customer/payment.dart';
import 'dart:convert';

import '../../model/order_product.dart';

class Cart extends StatefulWidget {
  final int? user_id;
  const Cart({
    super.key,
    required this.user_id,
  });

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<ProductPrice> productPrices = [];
  List<OrderProduct> carts = [];
  int user_id = 0;
  int order_id = 0;
  double totalAmount = 0;
  double taxAmount = 0;
  double total = 0;
  bool isOn = false; // bật nút button thanh toán
  int totalQuantity = 0; // số lượng hiển thị lên giỏ hàng
  String productNameError =
      ''; // tên sản phẩm trong giỏ có số lượng lớn hơn trong kho

  @override
  void initState() {
    super.initState();
    if (widget.user_id != null) {
      user_id = widget.user_id!;
    }

    print('User ID: $user_id');
    carts.clear();
    fetchDataCarts();
  }

  Future<void> fetchDataCarts() async {
    await fetchCartOfUser(user_id);
    if (carts.isNotEmpty) {
      order_id = carts[0].orderId;
      await fetchTotalOfCart(order_id);
      isOn = true;
      print('Order ID: $order_id');
    } else {
      for (final i in carts) {
        totalQuantity += i.quantity;
      }
      Provider.of<DataShare>(context, listen: false)
          .setCartItemCount(totalQuantity);
      print('TotalQ: $totalQuantity');
    }
  }

  Future<void> fetchCartOfUser(int userId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/user/getCartOfUser');
    final apiUrlWithParams =
        url.replace(queryParameters: {'user_id': userId.toString()});
    try {
      final response = await http.get(apiUrlWithParams);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'] != null) {
          final List<dynamic> bodyData = data['body'];
          // order_id = int.parse(data['body']['order_id']);
          setState(() {
            carts =
                bodyData.map((json) => OrderProduct.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      print('Lỗi fetchCartOfUser');
      print('Error: $e');
    }
  }

  Future<void> fetchTotalOfCart(int orderId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/order/getTotalOfCart');
    final apiUrlWithParams =
        url.replace(queryParameters: {'order_id': orderId.toString()});
    try {
      final response = await http.get(apiUrlWithParams);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'] != null) {
          setState(() {
            totalAmount =
                double.parse(data['body'][0]['total_amount'].toString());
            taxAmount = double.parse(data['body'][0]['tax_amount'].toString());
            total = totalAmount + taxAmount;
          });
        }
      }
    } catch (e) {
      print('Lỗi fetchCartOfUser');
      print('Error: $e');
    }
  }

  Future<void> fetchDeleteProductOfCart(int orderId, int productId) async {
    final url =
        Uri.parse('http://10.0.2.2:8080/api/v1/order/deleteProductOfCart');
    final apiUrlWithParams = url.replace(queryParameters: {
      'order_id': orderId.toString(),
      'product_id': productId.toString()
    });
    try {
      final response = await http.delete(apiUrlWithParams);
      if (response.statusCode == 200) {
        print('delete');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi fetchCartOfUser');
      print('Error: $e');
    }
  }

  Future<void> fetchUpdateQuantityProductOrder(
      int orderId, int productId, int quantity) async {
    final url = Uri.parse(
        'http://10.0.2.2:8080/api/v1/order/updateQuantityProductOrder');
    final apiUrlWithParams = url.replace(queryParameters: {
      'order_id': orderId.toString(),
      'product_id': productId.toString(),
      'quantity': quantity.toString(),
    });
    try {
      final response = await http.put(apiUrlWithParams);
      if (response.statusCode == 200) {
      } else {
        print('Error fetchUpdateQuantityProductOrder: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi fetchUpdateQuantityProductOrder');
      print('Error: $e');
    }
  }

  void _removeCartItem(OrderProduct cart) async {
    setState(() {
      carts.remove(cart);
      Provider.of<DataShare>(context, listen: false).subToCart(cart.quantity);
      totalQuantity = totalQuantity - cart.quantity;
      if (carts.isEmpty) {
        isOn = false;
        totalQuantity = 0;
        Provider.of<DataShare>(context, listen: false).setCartItemCount(0);
      }
    });
    await fetchDeleteProductOfCart(cart.orderId, cart.productId);
    await fetchTotalOfCart(cart.orderId);
  }

  void _showMoreOptions(BuildContext context, OrderProduct cart) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 115,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Xem thông tin sản phẩm'),
                onTap: () {
                  // Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return InfoProduct(
                      productId: cart.productId,
                      userId: user_id,
                      check: 1,
                    );
                  }));
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Xoá sản phẩm khỏi giỏ hàng'),
                onTap: () {
                  _removeCartItem(cart);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateCart(
    int orderId,
    int productId,
    int quantity,
  ) async {
    print('dd: $orderId $productId $quantity ');
    await fetchUpdateQuantityProductOrder(orderId, productId, quantity);

    await fetchTotalOfCart(orderId);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 40, left: 15, bottom: 10, right: 15),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Giỏ hàng',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),
                // ====================================================================
                SizedBox(
                  height: 375,
                  child: carts.isEmpty
                      ? const SizedBox(
                          height: 15,
                          child: Text(
                            'Bạn chưa thêm sản phẩm vào giỏ hàng',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFFFFA013),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: carts.map((cart) {
                              print(totalQuantity);

                              return CartBody(
                                cart,
                                cart.picture,
                                cart.productName,
                                cart.quantity,
                                cart.price,
                                () {
                                  onDecrease(cart, context);
                                },
                                () async {
                                  await onIncrease(cart, context);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),
          // const SizedBox(
          //   height: 5,
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Opacity(
                      opacity: 0.5,
                      child: Text(
                        'Tổng giá sản phẩm:',
                        style: TextStyle(fontSize: 17, color: Colors.black),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: NumberFormat.decimalPattern()
                                .format(totalAmount)
                                .toString(),
                            style: const TextStyle(
                              color: Color(0xFFFFA013),
                              fontSize: 17,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                          const TextSpan(
                            text: ' ₫',
                            style: TextStyle(
                              color: Color(0xFFFFA013),
                              fontSize: 17,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Opacity(
                      opacity: 0.5,
                      child: Text(
                        'Tổng thuế:',
                        style: TextStyle(fontSize: 17, color: Colors.black),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: NumberFormat.decimalPattern()
                                .format(taxAmount)
                                .toString(),
                            style: const TextStyle(
                              color: Color(0xFFFFA013),
                              fontSize: 17,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                          const TextSpan(
                            text: ' ₫',
                            style: TextStyle(
                              color: Color(0xFFFFA013),
                              fontSize: 17,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Opacity(
                      opacity: 0.5,
                      child: Text(
                        'Tổng cộng:',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
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
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const TextSpan(
                            text: ' ₫',
                            style: TextStyle(
                              color: Color(0xFFFFA013),
                              fontSize: 20,
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
                    backgroundColor: isOn
                        ? MaterialStateProperty.all(const Color(0xFFFFA013))
                        : MaterialStateProperty.all(Colors.grey),
                    minimumSize: MaterialStateProperty.all(
                        const Size(double.infinity, 50)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  onPressed: isOn
                      ? () async {
                          if (carts.isNotEmpty) {
                            if (await checkQuantityBeforePayment()) {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return Payment(
                                  user_id: user_id,
                                  order_id: order_id,
                                  total: total,
                                  carts: carts,
                                );
                              }));
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    title: const Text('Thông báo'),
                                    content: Text(
                                      'Số lượng sản phẩm trong giỏ đã vượt quá số lượng hàng có sẵn.\n$productNameError',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Đóng'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        }
                      : null,
                  child: const Text(
                    'Thanh toán',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void onDecrease(OrderProduct cart, BuildContext context) {
    if (cart.quantity > 1) {
      Provider.of<DataShare>(context, listen: false).subToCart(1);
      cart.quantity--;
      totalQuantity -= 1;
      _updateCart(order_id, cart.productId, cart.quantity);
    }
  }

  Future<void> onIncrease(OrderProduct cart, BuildContext context) async {
    if (cart.quantity <
        await fetchProductQuantityById(context, cart.productId)) {
      Provider.of<DataShare>(context, listen: false).addToCart(1);
      cart.quantity++;
      totalQuantity = totalQuantity + 1;
      _updateCart(order_id, cart.productId, cart.quantity);
    } else {
      showShortSnackBar(context, 'Đã đạt tối đa số lượng hàng có sẵn');
    }
  }

  Future<bool> checkQuantityBeforePayment() async {
    bool check = true;
    for (OrderProduct cart in carts) {
      int quantityW = await fetchProductQuantityById(context, cart.productId);

      check = await checkQuantityInWareHouse(
          order_id, cart.productId, quantityW, false);

      if (check == false) {
        setState(() {
          productNameError = cart.productName;
        });
        return check;
      }
    }
    return check;
  }

  Container CartBody(
      OrderProduct cartUser,
      String picture,
      String name,
      int quantity,
      double price,
      VoidCallback onDecrease,
      VoidCallback onIncrease) {
    return Container(
      width: double.infinity,
      height: 110,
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
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  width: 190,
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(top: 15),
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18),
                  ))),
          Positioned(
            bottom: 13,
            left: 110,
            child: InkWell(
              onTap: onDecrease,
              child: Container(
                width: 35,
                height: 35,
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: StadiumBorder(),
                  shadows: [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.remove, color: Colors.black),
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 158,
            child: Container(
              child: Text(
                quantity.toString(),
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),
          Positioned(
            bottom: 13,
            left: 185,
            child: InkWell(
              onTap: onIncrease,
              child: Container(
                width: 35,
                height: 35,
                decoration: const ShapeDecoration(
                  color: Colors.white,
                  shape: StadiumBorder(),
                  shadows: [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ),
          ),

          Positioned(
              left: 350,
              child: InkWell(
                onTap: () {
                  _showMoreOptions(context, cartUser);
                },
                child: Container(
                    width: 190,
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(top: 15),
                    child: const Icon(Icons.more_vert, color: Colors.black)),
              )),

          Positioned(
            bottom: 17,
            // left: 0,
            right: 15,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: NumberFormat.decimalPattern()
                        .format(price * quantity)
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
    );
  }
}
