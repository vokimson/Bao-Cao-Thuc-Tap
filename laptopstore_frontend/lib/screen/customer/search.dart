// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:storelaptop/screen/customer/dataShare.dart';

import '../../model/product.dart';
import '../../model/product_price.dart';
import '../../model/product_warehouse.dart';
import 'home.dart';

class SearchProduct extends StatefulWidget {
  final int userId;
  const SearchProduct({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  int userId = 0;
  TextEditingController searchController = TextEditingController();
  List<Product> productList = [];
  List<ProductPrice> productPrices = [];
  bool check = false; // kiêm tra nhấn tìm kiếm thì cập nhật lại danh sách
  List<ProductWarehouse> productQuantities = [];

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    productList.clear();
    fetchPriceOfProduct();
    awaiProductQuantity();
  }

  Future<void> awaiProductQuantity() async {
    List<ProductWarehouse> temp =
        await fetchGetProductQuantityOfWarehouse(context);
    setState(() {
      productQuantities = temp;
    });
  }

  Future<void> fetchSearchProduct(String search) async {
    Uri apiUrl =
        Uri.parse('http://10.0.2.2:8080/api/v1/product/getProductByName');
    final apiUrlWithParams = apiUrl.replace(queryParameters: {
      'product_name': search,
      'area': Provider.of<DataShare>(context, listen: false).selectArea,
    });

    try {
      final response = await http.get(apiUrlWithParams);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'] != null) {
          final List<dynamic> products = data['body'];
          productList.clear();
          setState(() {
            productList =
                products.map((json) => Product.fromJson(json)).toList();
            // print(productList);
          });
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
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
              print('QL:  ${productPrices.length}');
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

  // Future<List<ProductWarehouse>> fetchGetProductQuantity() async {
  //   final url =
  //       Uri.parse('http://10.0.2.2:8080/api/v1/product/getProductQuantity');

  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['body'] != null) {
  //         final bodyData = data['body'];
  //         if (bodyData is List) {
  //           productQuantities = bodyData
  //               .map((item) => ProductWarehouse.fromJson(item))
  //               .toList();
  //           return productQuantities;
  //         } else {
  //           print('Lỗi: Dữ liệu không hợp lệ');
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('Lỗi fetchGetProductQuantity');
  //     print('Error: $e');
  //   }

  //   return productQuantities;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Tìm kiếm sản phẩm',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 18, bottom: 10, right: 18),
            child: TextField(
              // onChanged: (value) => {textValue = value},
              controller: searchController,
              style: const TextStyle(fontSize: 17),
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                hintText: 'Tìm tên sản phẩm',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                suffixIcon: IconButton(
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      fetchSearchProduct(searchController.text);
                      check = true;
                      FocusScope.of(context).unfocus();
                    }
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  fetchSearchProduct(value);
                  check = true;
                  print('Đã nhấn Enter với giá trị: $value');
                }
              },
            ),
          ),
          Container(
            height: 1,
            color: Colors.black12,
          ),
          const SizedBox(
            height: 10,
          ),
          if (check)
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: productList.isNotEmpty
                  ? const Text(
                      'Kết quả tìm kiếm',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  : const Center(
                      child: Text(
                        'Không tìm thấy kết quả',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: SingleChildScrollView(
              // Chỉ cuộn phần GridView
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 150 / 240,
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
                            (quantity) =>
                                quantity.productId == product.productId,
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
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
