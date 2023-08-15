// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storelaptop/home.dart';
import 'package:storelaptop/model/customer.dart';

import 'package:storelaptop/screen/customer/InfoProduct.dart';
import 'package:storelaptop/screen/customer/cart.dart';
import 'package:storelaptop/screen/customer/mypage.dart';

import '../../model/product.dart';
import '../../model/product_price.dart';
import '../../model/product_warehouse.dart';
import '../../screen/customer/store.dart';
import 'dataShare.dart';

class CustomerHome extends StatefulWidget {
  final int user_id;
  int checkTab;
  CustomerHome({
    Key? key,
    required this.user_id,
    required this.checkTab,
  }) : super(key: key);

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int userId = 0;
  int checkTab = 0;
  // int cartItemCount = 0;
  // _CustomerHomeState({required this.user_id});

  int _currentIndex = 0;
  void checkCurrentTab(int tab) {
    _currentIndex = tab;
  }

  @override
  void initState() {
    super.initState();
    userId = widget.user_id;
    checkTab = widget.checkTab;
    checkCurrentTab(checkTab);
  }

  @override
  Widget build(BuildContext context) {
    int cartItemCount = Provider.of<DataShare>(context).cartItemCount;

    final tabs = [
      TabHome(userId: userId),
      TabStore(userId: userId),
      Cart(user_id: userId),
      MyPage(userId: userId),
    ];

    return WillPopScope(
      onWillPop: () async {
        bool confirmLogout = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Xác nhận đăng xuất'),
              content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Đăng xuất'),
                ),
              ],
            );
          },
        );

        if (confirmLogout == true) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const MyApp();
              },
            ),
            (Route<dynamic> route) => false,
          );
        }
        return false;
      },
      child: Scaffold(
        body: tabs[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          fixedColor: Colors.amber,
          iconSize: 30,
          items: [
            const BottomNavigationBarItem(
              label: 'Trang Chủ',
              icon: Icon(Icons.home),
            ),
            const BottomNavigationBarItem(
              label: 'Cửa hàng',
              icon: Icon(Icons.shopping_cart),
            ),
            BottomNavigationBarItem(
              label: 'Giỏ hàng',
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_bag),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartItemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const BottomNavigationBarItem(
              label: 'Tài khoản',
              icon: Icon(Icons.account_circle),
            ),
          ],
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class TabHome extends StatefulWidget {
  final int userId;
  const TabHome({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> with WidgetsBindingObserver {
  List<ProductPrice> productPrices = [];
  List<Product> productList = [];

  List<ProductWarehouse> productQuantities = [];

  int userId = 0;
  int customerId = 0;
  // User user = User(
  //     userId: 0,
  //     email: '',
  //     password: '',
  //     fullName: '',
  //     dateOfBirth: '',
  //     phone: '',
  //     address: '',
  //     customerId: 0);
  Customer customer = Customer(
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
  bool hasError = false;
  int order_id = 0;
  String selectedArea = '';
  List<String> areas = [];
  bool isFirstLogin = false;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;

    awaitData();
  }

  Future<void> awaitData() async {
    order_id = await fetchCartOfUser(userId);
    if (order_id != 0) {
      await fetchGetProductQuantityOfOrder(order_id);
    }
    Customer customer1 = await fetchCustomerInfo(userId);
    setState(() {
      customer = customer1;
    });
    print('CusA: ${customer.shopping_area}');
    await fetchGetAllAreaWarehouse();
    print('AREAS: ${areas.length}');
    Provider.of<DataShare>(context, listen: false).setUserId(userId);
    Provider.of<DataShare>(context, listen: false).setAreas(areas);
    Provider.of<DataShare>(context, listen: false)
        .setSelectArea(customer.shopping_area);

    List<ProductWarehouse> temp =
        await fetchGetProductQuantityOfWarehouse(context);
    if (temp.isEmpty) {
      print('Empty Quanlity Product Warehouse!');
    }
    setState(() {
      customerId = customer.customerId ?? 0;
      productQuantities = temp;
    });

    await fetchNewProducts();
    await fetchPriceOfProduct();
    bool firstLogin = await fetchGetFirstLogin(customerId);

    if (firstLogin) {
      // hiện dialog khi vừa vào screen
      WidgetsBinding.instance.addObserver(this);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted &&
            WidgetsBinding.instance.lifecycleState ==
                AppLifecycleState.resumed) {
          // await fetchGetShoppingAreaOfCustomer(customerId);

          await fetchUpdateFirstLogin(customerId);
          _showLocationDialog();
        }
      });
    }
  }

  Future<bool> fetchGetFirstLogin(int customerId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/getFirstLogin');
    final apiUrlParam = url.replace(queryParameters: {
      'customer_id': customerId.toString(),
    });
    try {
      final response = await http.get(apiUrlParam);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final body = data['body'];
        if (body is List && body.isNotEmpty) {
          final firstLogin = body[0]['first_login'];
          print('FLG: $firstLogin');
          return firstLogin == 0 ? true : false;
        }
      }
    } catch (error) {
      print('Lỗi fetchGetFirstLogin');
      print('Error: $error');
    }
    return false;
  }

  Future<bool> fetchUpdateFirstLogin(int customerId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/updateFirstLogin');
    final apiUrlParam = url.replace(queryParameters: {
      'customer_id': customerId.toString(),
    });
    try {
      final response = await http.put(apiUrlParam);
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Lỗi fetchUpdateFirstLogin');
        print(response.statusCode);
      }
    } catch (error) {
      print('Lỗi fetchUpdateFirstLogin');
      print('Error: $error');
    }
    return false;
  }

  // Future<void> fetchGetShoppingAreaOfCustomer(int customerId) async {
  //   final url =
  //       Uri.parse('http://10.0.2.2:8080/api/v1/user/getShoppingAreaOfCustomer');
  //   final apiUrlParam = url.replace(queryParameters: {
  //     'customer_id': customerId.toString(),
  //   });
  //   try {
  //     final response = await http.get(apiUrlParam);
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       String area = data['body'][0]['shopping_area'];
  //       setState(() {
  //         Provider.of<DataShare>(context, listen: false).setSelectArea(area);
  //       });
  //     } else {
  //       print('Lỗi fetchGetShoppingAreaOfCustomer');
  //       print(response.statusCode);
  //     }
  //   } catch (error) {
  //     print('Lỗi fetchGetShoppingAreaOfCustomer');
  //     print('Error: $error');
  //   }
  // }

  Future<void> fetchGetAllAreaWarehouse() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/getAllAreaWarehouse');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'].isNotEmpty) {
          List<dynamic> provinceData = data['body'];

          for (var province in provinceData) {
            setState(() {
              areas.add(province['area']);
            });
          }
          // Provider.of<DataShare>(context).setAreas(areas);
        } else {
          print('Data not found');
        }
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print('Lỗi fetchGetAllAreaWarehouse');
      print('Error: $e');
    }
  }

  Future<void> fetchGetProductQuantityOfOrder(int orderId) async {
    final url = Uri.parse(
        'http://10.0.2.2:8080/api/v1/product/getProductQuantityOfOrder');
    final apiUrlParam = url.replace(
      queryParameters: {
        'order_id': orderId.toString(),
      },
    );
    try {
      final response = await http.get(apiUrlParam);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['body'] != null && data['body'].isNotEmpty) {
          int totalQuantity = int.parse(data['body'][0]['quantity'].toString());
          Provider.of<DataShare>(context, listen: false)
              .setCartItemCount(totalQuantity);
        } else {
          print('Empty Cart! fetchGetProductQuantityOfOrder');
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Lỗi fetchGetProductQuantityOfOrder');
      print('Error: $error');
    }
  }

  Future<int> fetchCartOfUser(int userId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/user/getCartOfUser');
    final apiUrlWithParams =
        url.replace(queryParameters: {'user_id': userId.toString()});
    try {
      final response = await http.get(apiUrlWithParams);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'] != null && data['body'].isNotEmpty) {
          final orderId = int.parse(data['body'][0]['order_id'].toString());
          return orderId;
        }
      }
    } catch (e) {
      print('Lỗi fetchCartOfUser');
      print('Error: $e');
    }
    return 0;
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

  Future<void> fetchNewProducts() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/getNewProducts');
    final apiUrlParam = url.replace(queryParameters: {
      'shopping_area':
          Provider.of<DataShare>(context, listen: false).selectArea,
    });
    try {
      final response = await http.get(apiUrlParam);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'] != null) {
          final List<dynamic> products = data['body'];

          setState(() {
            productList =
                products.map((json) => Product.fromJson(json)).toList();
          });
        }
      } else {
        print('Error: fetchNewProducts');
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: 300.0,
            height: 170,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Địa điểm mua hàng của bạn',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12.0),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: areas.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(areas[index]),
                        onTap: () => _onLocationTap(context, areas[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onLocationTap(BuildContext context, String selectedArea) async {
    Provider.of<DataShare>(context, listen: false).setSelectArea(selectedArea);
    await fetchUpdateShoppingArea(selectedArea, customerId);
    await fetchNewProducts();

    setState(() {
      this.selectedArea = selectedArea;
      // print(selectedArea);
      Provider.of<DataShare>(context, listen: false)
          .setSelectArea(selectedArea);

      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 520,
                child: Image.asset(
                  'assets/home_1.png',
                  fit: BoxFit.cover,
                ),
              ),
              const Positioned(
                bottom: 20,
                left: 20,
                child: Text(
                  'Laptop\nStore',
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 7,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sản phẩm mới',
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
          const SizedBox(height: 17),
          productList.isNotEmpty
              ? GridView.builder(
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
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
                            final productQuantity =
                                productQuantities.firstWhere(
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
                )
              : const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Text(
                      'Hiện chưa có sản phẩm mới!',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

bool isNewProduct = false;
bool _isNewProduct(DateTime createDate) {
  final now = DateTime.now();
  final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
  return createDate.isAfter(sixMonthsAgo);
}

Widget buildProductContainer(
    BuildContext context,
    String imageUrl,
    String name,
    double price,
    DateTime createDate,
    int productId,
    int userId,
    int quantity) {
  return GestureDetector(
    onTap: () {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return InfoProduct(
          productId: productId,
          userId: userId,
          check: 0,
        );
      }));
    },
    child: SizedBox(
      width: 150,
      height: 250,
      child: Stack(
        children: [
          Container(
            width: 165,
            height: 195,
            decoration: ShapeDecoration(
              color: const Color(0xFFC4C4C4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: imageUrl.isNotEmpty
                ? SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
          if (_isNewProduct(createDate))
            Positioned(
              left: 10,
              top: 5,
              child: Container(
                alignment: Alignment.center,
                width: 45,
                height: 25,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                ),
                child: const Text(
                  'NEW',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(left: 5, top: 200),
            child: SizedBox(
              width: 148,
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 5, top: 240),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        NumberFormat.decimalPattern().format(price).toString(),
                    style: const TextStyle(
                      color: Color(0xFFFFA013),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                  const TextSpan(
                    text: ' ₫',
                    style: TextStyle(
                      color: Color(0xFFFFA013),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
              margin: const EdgeInsets.only(left: 3, top: 260),
              child: quantity == 0
                  ? Container(
                      width: 95,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: ShapeDecoration(
                          color: Colors.red[50],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: const Text(
                        'Sắp về hàng',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 15),
                      ),
                    )
                  : null),
        ],
      ),
    ),
  );
}

int setCurrentTabIsCart() {
  var currentIndex = 2;
  return currentIndex;
}

Future<List<ProductWarehouse>> fetchGetProductQuantityOfWarehouse(
    BuildContext context) async {
  final url = Uri.parse(
      'http://10.0.2.2:8080/api/v1/product/getProductQuantityOfWarehouse');
  final apiParam = url.replace(queryParameters: {
    'shopping_area': Provider.of<DataShare>(context, listen: false).selectArea,
  });
  List<ProductWarehouse> productQuantities = [];
  try {
    final response = await http.get(apiParam);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['body'] != null) {
        final bodyData = data['body'];
        if (bodyData is List) {
          productQuantities =
              bodyData.map((item) => ProductWarehouse.fromJson(item)).toList();
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
