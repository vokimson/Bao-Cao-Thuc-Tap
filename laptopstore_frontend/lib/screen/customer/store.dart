// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:storelaptop/screen/customer/dataShare.dart';

import 'package:storelaptop/screen/customer/search.dart';

import '../../model/product.dart';
import '../../model/product_price.dart';
import '../../model/product_warehouse.dart';
import '../../screen/customer/home.dart';

class TabStore extends StatefulWidget {
  int userId;
  TabStore({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<TabStore> createState() => _TabStoreState();
}

class _TabStoreState extends State<TabStore> {
  int userId = 0;
  List<String> tabs = [];
  int selectedTabIndex = 0;
  List<Product> productList = [];
  List<ProductPrice> productPrices = [];
  double price = 0;
  List<ProductWarehouse> productQuantities = [];
  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    fetchListManufacturerWithProduct();
    awaiProductQuantity();
  }

  Future<void> awaiProductQuantity() async {
    await fetchGetProductQuantityOfWarehouse();
  }

  // lấy danh sách các hãng
  Future<void> fetchListManufacturerWithProduct() async {
    final url =
        Uri.parse('http://10.0.2.2:8080/api/v1/getListManufacturerWithProduct');
    final apiParam = url.replace(queryParameters: {
      'shopping_area':
          Provider.of<DataShare>(context, listen: false).selectArea,
    });
    try {
      final response = await http.get(apiParam);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['manufacturerNames'] != null) {
          setState(() {
            tabs = List<String>.from(data['manufacturerNames']);
            print(tabs);
            fetchProductsOfManufacturer(tabs[selectedTabIndex]);
          });
        }
      } else {
        print('Error: fetchListManufacturerWithProduct');
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // lấy danh sách sp theo hãng
  Future<void> fetchProductsOfManufacturer(String manufacturerName) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/getProductsOfManu');
    // final headers = {'Content-Type': 'application/json'};
    // final body = json.encode({'manufacturer_name': manufacturerName});

    // final response = await http.post(url, headers: headers, body: body);
    final apiUrlWithParams = url.replace(queryParameters: {
      'manufacturer_name': manufacturerName,
      'shopping_area':
          Provider.of<DataShare>(context, listen: false).selectArea,
    });
    try {
      final response = await http.get(apiUrlWithParams);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['body'] != null) {
          final List<dynamic> products = data['body'];

          setState(() {
            productList =
                products.map((json) => Product.fromJson(json)).toList();
            // print(productList);
          });
        } else {
          print('Error: Invalid response data');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi fetchProductsOfManufacturer');
      print('Error: $e');
    }
  }

  Future<List<ProductPrice>> fetchPriceOfProduct() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/getPriceOfProduct');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'] != null) {
          final bodyData = data['body'];
          if (bodyData is List) {
            for (var item in bodyData) {
              final productPriceData = ProductPrice.fromJson(item);
              productPrices.add(productPriceData);
            }
          } else {
            print('Lỗi: Dữ liệu không hợp lệ');
          }
        }
      }
    } catch (e) {
      print('Lỗi fetchPriceOfProduct');
      print('Error: $e');
    }

    return productPrices;
  }

  Future<List<ProductWarehouse>> fetchGetProductQuantityOfWarehouse() async {
    final url = Uri.parse(
        'http://10.0.2.2:8080/api/v1/product/getProductQuantityOfWarehouse');
    final apiParam = url.replace(queryParameters: {
      'shopping_area':
          Provider.of<DataShare>(context, listen: false).selectArea,
    });
    try {
      final response = await http.get(apiParam);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'] != null) {
          final bodyData = data['body'];
          if (bodyData is List) {
            productQuantities = bodyData
                .map((item) => ProductWarehouse.fromJson(item))
                .toList();
            return productQuantities;
          } else {
            print('Lỗi: Dữ liệu không hợp lệ');
          }
        }
      }
    } catch (e) {
      print('Lỗi fetchGetProductQuantity');
      print('Error: $e');
    }

    return productQuantities;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 50, left: 10, bottom: 20, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Cửa hàng',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    print('object');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return SearchProduct(userId: userId);
                    }));
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 35,
                  ),
                ),
              ],
            ),
            const Opacity(
              opacity: 0.5,
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  'Chọn sản phẩm theo thương hiệu',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedTabIndex = index;
                          fetchProductsOfManufacturer(tabs[index]);
                          print(tabs[index]);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedTabIndex == index
                            ? Colors.amber // Màu nền cho button được nhấn
                            : Colors
                                .black, // Màu nền mặc định cho các button khác
                      ),
                      child: Text(tabs[index]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              height: 1,
              color: Colors.black12,
            ),
            SizedBox(
              height: 0.1,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 150 / 250,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: productList.length,
              itemBuilder: (context, index) {
                final product = productList[index];
                return FutureBuilder<List<ProductPrice>>(
                  future: fetchPriceOfProduct(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print('ConnectionState.waiting');
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      print('Error loading datag');
                      return const Center(
                        child: Text('Error loading data'),
                      );
                    } else {
                      final productPrices = snapshot.data ?? [];
                      final productPrice = productPrices.firstWhere(
                        (price) => price.productId == product.productId,
                        orElse: () => ProductPrice(price: 0, productId: 0),
                      );

                      if (productPrice.productId == 0) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        final productQuantity = productQuantities.firstWhere(
                          (quantity) => quantity.productId == product.productId,
                          orElse: () => ProductWarehouse(
                              productId: 0, quantity: 0, warehouseId: null),
                        );
                        return buildProductContainer(
                          context,
                          product.picture,
                          product.name,
                          productPrice.price,
                          product.createDate,
                          product.productId,
                          userId,
                          productQuantity.quantity,
                        );
                      }
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
