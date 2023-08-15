// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storelaptop/screen/customer/dataShare.dart';

import 'package:storelaptop/screen/customer/home.dart';

import '../../model/product.dart';
import '../../model/product_warehouse.dart';

class InfoProduct extends StatefulWidget {
  int productId;
  int userId;
  int check;

  InfoProduct({
    Key? key,
    required this.productId,
    required this.userId,
    required this.check,
  }) : super(key: key);

  @override
  State<InfoProduct> createState() => _InfoProductState();
}

class _InfoProductState extends State<InfoProduct> {
  Product product = Product(
    productId: 0,
    name: 'EEE',
    series: '',
    screen: '',
    cpu: '',
    ram: '',
    hardware: '',
    graphicCard: '',
    operatingSystem: '',
    warranty: 0,
    battery: '',
    weight: '',
    content: '',
    picture: '',
    createDate: DateTime(2000),
    manufacturerId: 0,
    vendorId: 0,
    taxId: 0,
  );
  int check = 0;
  int userId = 0;
  int orderId = 0;
  int productId = 0;
  double price = 0;
  String manufacturerName = '';
  String vendorName = '';
  bool isLoading = true;
  int productQuantity = 0;
  List<ProductWarehouse> productQuantities = [];

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    productId = widget.productId;
    check = widget.check;

    awaitFetchProductInfo(productId);
    // fetchProductQuantityById(productId);
  }

  Future<void> awaitFetchProductInfo(int productId) async {
    try {
      await fetchProductInfo(productId);
      int fetchProductQuantity =
          await fetchProductQuantityById(context, productId);
      setState(() {
        isLoading = false;
        productQuantity = fetchProductQuantity;
      });
    } catch (e) {
      print('Lỗi fetchProductInfo');
      print('Error: $e');
    }
  }

  Future<void> fetchProductInfo(int productId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/product/getProductById');
    final apiUrlWithParams =
        url.replace(queryParameters: {'product_id': productId.toString()});
    try {
      final response = await http.get(apiUrlWithParams);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['body'] != null) {
          product = Product.fromJson(data['body'][0]);

          price = double.parse(data['body'][0]['price'].toString());
          manufacturerName = data['body'][0]['manufacturer_name'].toString();
          vendorName = data['body'][0]['vendor_name'].toString();
        }
      }
    } catch (e) {
      print('Lỗi fetchProductInfo');
      print('Error: $e');
    }
  }

  Future<bool> fetchGetProcessingOrder(int userId) async {
    final url =
        Uri.parse('http://10.0.2.2:8080/api/v1/order/getOrderProcessingOfUser');
    final apiUrlWithParams =
        url.replace(queryParameters: {'user_id': userId.toString()});
    try {
      final response = await http.get(apiUrlWithParams);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        orderId = data['body'][0]['order_id'];
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Lỗi fetchGetProcessingOrder');
      print('Error: $e');
    }
    return false;
  }

  Future<bool> fetchCreateOrder(int userId, int productId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/order/createOrder');

    var body = {
      'user_id': userId.toString(),
      'product_id': productId.toString(),
    };
    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        print('Create Order');
        return true;
      } else {
        print('Error fetchCreateOrder: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Lỗi fetchCreateOrder');
      print('Error: $e');
    }
    return false;
  }

  Future<bool> fetchAddProductToOrder(int orderId, int productId) async {
    final url =
        Uri.parse('http://10.0.2.2:8080/api/v1/order/addProductToOrder');

    var body = {
      'order_id': orderId.toString(),
      'product_id': productId.toString(),
    };
    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Lỗi fetchAddProductToOrder');
        print(response.statusCode);
        return false;
      }
    } catch (e) {
      print('Lỗi fetchAddProductToOrder');
      print('Error: $e');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (check == 1) {
          // Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) {
              return CustomerHome(user_id: userId, checkTab: 2);
            }),
            // (Route<dynamic> route) => false,
          );
        } else {
          Navigator.pop(context);
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (BuildContext context) {
          //     return CustomerHome(user_id: userId, checkTab: 0);
          //   }),
          //   // (Route<dynamic> route) => false,
          // );
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Thông tin sản phẩm',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SizedBox(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      if (!isLoading && product.picture.isNotEmpty)
                        SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: Image.network(
                            product.picture.toString(),
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(17.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              // product.name.toString(),
                              maxLines: null,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: NumberFormat.decimalPattern()
                                              .format(price)
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
                                  // Opacity(
                                  //     opacity: 0.5,
                                  //     child: Text(
                                  //       'Còn lại: $productQuantity',
                                  //       style: const TextStyle(fontSize: 16),
                                  //     )),
                                ]),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                                child: productQuantity == 0
                                    ? Container(
                                        width: 140,
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: ShapeDecoration(
                                            color: Colors.red[50],
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15))),
                                        child: const Text(
                                          'Sắp về hàng',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 20),
                                        ),
                                      )
                                    : null),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              product.content,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(fontSize: 17),
                            ),
                            const SizedBox(
                              height: 26,
                            ),
                            const Text(
                              'Thông số kỹ thuật',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Thông tin chung',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  InfoBody('Thương hiệu:', manufacturerName),
                                  InfoBody('Series:', product.series),
                                  InfoBody(
                                      'Bảo hành:', product.warranty.toString()),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cấu hình chi tiết',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  InfoBody('Thế hệ CPU:', product.cpu),
                                  InfoBody('VGA:', product.graphicCard),
                                  InfoBody('RAM:', product.ram),
                                  InfoBody('Ổ cứng:', product.hardware),
                                  InfoBody('Màn hình:', product.screen),
                                  InfoBody(
                                      'Hệ điều hành:', product.operatingSystem),
                                  InfoBody('Pin:', product.battery),
                                  InfoBody('Cân nặng:', product.weight),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: productQuantity == 0
                        ? MaterialStateProperty.all(Colors.grey)
                        : MaterialStateProperty.all(const Color(0xFFFFA013)),
                    minimumSize: MaterialStateProperty.all(
                      const Size(double.infinity, 50),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  onPressed: productQuantity != 0
                      ? () async {
                          print('add to cart: $userId, $orderId, $productId');
                          if (await fetchGetProcessingOrder(userId)) {
                            if (await checkQuantityInWareHouse(
                                orderId, productId, productQuantity, true)) {
                              if (await fetchAddProductToOrder(
                                  orderId, productId)) {
                                Provider.of<DataShare>(context, listen: false)
                                    .addToCart();
                                showShortSnackBar(
                                    context, 'Đã thêm sản phẩm vào giỏ hàng');
                              }
                            } else {
                              showShortSnackBar(context,
                                  'Đã đạt tối đa số lượng hàng có sẵn');
                            }
                          } else {
                            if (await fetchCreateOrder(userId, productId)) {
                              Provider.of<DataShare>(context, listen: false)
                                  .addToCart();
                              showShortSnackBar(
                                  context, 'Đã thêm sản phẩm vào giỏ hàng');
                            } else {
                              showShortSnackBar(
                                  context, 'Đã xảy ra lỗi vui lòng thử lại');
                            }
                          }
                        }
                      : null,
                  child: const Text(
                    'Thêm vào giỏ hàng',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
                        color: Color(0xFFFFA013),
                        fontSize: 18,
                      )),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 230),
                      child: Text(
                        right,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        maxLines: null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    ),
  );
}

void showShortSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<int> fetchProductQuantityById(
    BuildContext context, int productId) async {
  final url =
      Uri.parse('http://10.0.2.2:8080/api/v1/product/getProductQuantityById');
  final apiUrlWithParams = url.replace(queryParameters: {
    'product_id': productId.toString(),
    'shopping_area': Provider.of<DataShare>(context, listen: false).selectArea,
  });
  try {
    final response = await http.get(apiUrlWithParams);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['body'] != null && data['body'].isNotEmpty) {
        int productQuantity = int.parse(data['body'][0]['quantity'].toString());

        return productQuantity;
      }
    }
  } catch (e) {
    print('Lỗi fetchProductQuantityById');
    print('Error: $e');
  }
  return 0;
}

Future<int> fetchGetQuantityOfProductWithCart(
    int orderId, int productId) async {
  final url =
      Uri.parse('http://10.0.2.2:8080/api/v1/getQuantityOfProductWithCart');
  final apiUrlWithParams = url.replace(queryParameters: {
    'order_id': orderId.toString(),
    'product_id': productId.toString(),
  });
  try {
    final response = await http.get(apiUrlWithParams);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['body'] != null && data['body'].isNotEmpty) {
        int quantity = data['body'][0]['quantity'];
        return quantity;
      }
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Lỗi fetchGetQuantityOfProductWithCart');
    print('Error: $e');
  }
  return 0;
}

Future<bool> checkQuantityInWareHouse(
    int orderId, int productId, int productQuantity, bool check) async {
  int quantityPC = await fetchGetQuantityOfProductWithCart(orderId, productId);
  if (check) {
    // kiểm tra trong InfoProduct
    if (quantityPC >= productQuantity) {
      return false;
    }
    return true;
  } else {
    // kiểm tra trong cart
    if (quantityPC > productQuantity) {
      return false;
    }
    return true;
  }
}
