// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:storelaptop/home.dart';
import 'package:storelaptop/screen/customer/dataShare.dart';
import 'package:storelaptop/screen/customer/mypageHistoryOrder.dart';
import 'package:storelaptop/screen/customer/mypage_order_tracking.dart';
import 'package:storelaptop/screen/customer/mypage_update.dart';

import '../../model/customer.dart';

class MyPage extends StatefulWidget {
  int userId;
  MyPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int userId = 0;

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
  // String? selectedAddress;

  List<String> areas = [];

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    awaitInfo();
    fetchGetAllAreaWarehouse();
  }

  Future<void> awaitInfo() async {
    Customer customer1 = await fetchCustomerInfo(userId);
    setState(() {
      customer = customer1;
    });
  }

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
        } else {
          print('Data not found');
        }
      } else {
        print('Error fetchGetAllAreaWarehouse: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi fetchGetAllAreaWarehouse');
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                customer.fullName,
                style:
                    const TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
              ),
              Opacity(
                opacity: 0.5,
                child: Text(
                  customer.phone,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    'Địa điểm mua hàng:',
                    style: TextStyle(fontSize: 17),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                      value: Provider.of<DataShare>(context).selectArea,
                      hint: const Text(
                        'Chọn địa chỉ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      elevation: 16,
                      // isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _updateShoppingArea(context, newValue);
                          // selectedAddress = newValue;
                        });
                      },
                      items: areas
                          .map((String address) => DropdownMenuItem<String>(
                                value: address,
                                child: Text(address),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyMyPage('Theo dõi đơn hàng', '', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return OrderTracking(userId: userId);
                }));
              }),
              Container(
                height: 2,
                // color: Colors.black12,
              ),
              BodyMyPage('Lịch sử mua hàng', '', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryOrder(),
                    ));
              }),
              Container(
                height: 2,
                // color: Colors.black12,
              ),
              BodyMyPage('Cập nhật thông tin', '', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return MyPageUpdate(userId: userId);
                })).then((value) {
                  setState(() {
                    awaitInfo();
                  });
                });
              }),
              Container(
                height: 2,
                // color: Colors.black12,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 70)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Xác nhận đăng xuất'),
                        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyApp()),
                              );
                            },
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đăng xuất',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        // SizedBox(
                        //   height: 5,
                        // ),
                        // Padding(
                        //   padding: EdgeInsets.only(left: 1),
                        //   child: Opacity(
                        //     opacity: 0.5,
                        //     child: Text(
                        //       'Thoát tài khoản này',
                        //       style: TextStyle(fontSize: 15),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> _updateShoppingArea(
      BuildContext context, String? newValue) async {
    Provider.of<DataShare>(context, listen: false).setSelectArea(newValue!);
    await fetchUpdateShoppingArea(
        Provider.of<DataShare>(context, listen: false).selectArea,
        customer.customerId!);
  }
}

ElevatedButton BodyMyPage(String top, String bot, VoidCallback onTap) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 70)),
    onPressed: onTap,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              top,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 1),
            //   child: Opacity(
            //     opacity: 0.5,
            //     child: Text(
            //       bot,
            //       style: const TextStyle(fontSize: 15),
            //     ),
            //   ),
            // ),
          ],
        ),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 30,
            ),
          ],
        ),
      ],
    ),
  );
}

Future<Customer> fetchCustomerInfo(int userId) async {
  final url = Uri.parse('http://10.0.2.2:8080/api/v1/user/getInfoCustomerById');
  final apiUrlWithParams =
      url.replace(queryParameters: {'user_id': userId.toString()});
  try {
    final response = await http.get(apiUrlWithParams);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['body'].isNotEmpty) {
        Customer customer = Customer.fromJson(data['body'][0]);
        print('Fet Cus: ${customer.phone}');
        return customer;
      } else {
        print('Data not found');
      }
    } else {
      print(response.statusCode);
    }
  } catch (e) {
    print('Lỗi fetchUserInfo');
    print('Error: $e');
  }
  return Customer(
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
}

Future<bool> fetchUpdateShoppingArea(
    String shoppingArea, int customerId) async {
  final url = Uri.parse('http://10.0.2.2:8080/api/v1/updateShoppingArea');
  print('object: $shoppingArea, $customerId');
  try {
    final response = await http.put(
      url,
      body: {
        'shopping_area': shoppingArea,
        'customer_id': customerId.toString(),
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Lỗi fetchUpdateShoppingArea');
      print(response.statusCode);
    }
  } catch (e) {
    print('Lỗi fetchUpdateShoppingArea');
    print('Error: $e');
  }

  return false;
}
