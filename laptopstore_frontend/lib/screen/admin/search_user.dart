import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:storelaptop/screen/admin/mypage_manage_user.dart';

import '../../model/customer.dart';
import 'package:http/http.dart' as http;

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  TextEditingController searchController = TextEditingController();
  List<Customer> customers = [];
  bool check =
      false; // kiêm tra nhấn tìm kiếm thì cập nhật lại danh sách (All Result..)

  @override
  void initState() {
    super.initState();
    customers.clear();
    awaitData();
  }

  Future<void> awaitData() async {}

  Future<List<Customer>> fetchGetUserByName(String fullName) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/admin/getUserByName');
    final apiParam = url.replace(queryParameters: {
      'full_name': fullName,
    });

    try {
      final response = await http.get(apiParam);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'].isNotEmpty) {
          final List<dynamic> usersData = data['body'];
          List<Customer> customers = [];
          customers = usersData.map((json) => Customer.fromJson(json)).toList();

          return customers;
        } else {
          print('Data not found');
        }
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print('Lỗi fetchGetUserByName');
      print('Error: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Tìm kiếm người dùng',
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
                hintText: 'Tìm theo tên/số điện thoại',
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                suffixIcon: IconButton(
                  onPressed: () async {
                    if (searchController.text.isNotEmpty) {
                      List<Customer> cus =
                          await fetchGetUserByName(searchController.text);
                      setState(() {
                        customers.clear();
                        customers.addAll(cus);
                      });

                      check = true;
                      FocusScope.of(context).unfocus();
                    }
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
              onSubmitted: (value) async {
                if (value.isNotEmpty) {
                  List<Customer> cus = await fetchGetUserByName(value);
                  setState(() {
                    customers.clear();
                    customers.addAll(cus);
                  });
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
              child: customers.isNotEmpty
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
                  crossAxisCount: 1,
                  // crossAxisSpacing: 16.0,
                  // mainAxisSpacing: 16.0,
                  childAspectRatio: 150 / 45,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  if (customer.customerId == null) {
                    return UserBody(customer.fullName, customer.phone, 1,
                        customer, null, context);
                  } else {
                    return UserBody(customer.fullName, customer.phone, 0,
                        customer, null, context);
                  }
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
