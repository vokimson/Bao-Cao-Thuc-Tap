import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:storelaptop/screen/admin/add_user.dart';
import 'package:storelaptop/screen/admin/info_user.dart';
import 'package:storelaptop/screen/admin/search_user.dart';

import '../../model/customer.dart';
import 'package:http/http.dart' as http;

import '../../model/user.dart';

class ManageUser extends StatefulWidget {
  const ManageUser({super.key});

  @override
  State<ManageUser> createState() => _ManageUserState();
}

class _ManageUserState extends State<ManageUser> {
  int selectedButtonIndex = 0;
  List<Customer> customers = [];
  List<User> admins = [];

  @override
  void initState() {
    super.initState();
    awaitData();
  }

  Future<void> awaitData() async {
    List<Customer> customers1 = await fetchAllCustomer();
    List<User> admins1 = await fetchAllAdmin();
    setState(() {
      customers.addAll(customers1);
      admins.addAll(admins1);
    });
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
          minimumSize: const Size(160, 45)),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Future<List<Customer>> fetchAllCustomer() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/admin/getAllCustomer');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'].isNotEmpty) {
          List<Customer> customers = [];

          for (var customerData in data['body']) {
            Customer customer = Customer.fromMap(customerData);
            customers.add(customer);
          }

          return customers;
        } else {
          print('Data not found');
        }
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print('Lỗi fetchAllCustomer');
      print('Error: $e');
    }
    return [];
  }

  Future<List<User>> fetchAllAdmin() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/admin/getAllAdmin');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'].isNotEmpty) {
          List<User> admins = [];

          for (var customerData in data['body']) {
            User admin = Customer.fromMap(customerData);
            admins.add(admin);
          }

          return admins;
        } else {
          print('Data not found');
        }
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print('Lỗi fetchAllAdmin');
      print('Error: $e');
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: ((context) => const AddUser())));
        },
        child: const Icon(
          Icons.add,
          size: 40,
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Quản lý người dùng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              print('object');
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return const SearchUser();
              }));
            },
            icon: const Icon(
              Icons.search,
              size: 35,
            ),
          ),
        ],
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
                    ButtonMethod(0, 'Khách hàng', () {
                      setState(() {
                        selectedButtonIndex = 0;
                      });
                    }),
                    ButtonMethod(1, 'Quản lý', () {
                      setState(() {
                        selectedButtonIndex = 1;
                      });
                    }),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: selectedButtonIndex == 0
                        ? customers.map((customer) {
                            return UserBody(customer.fullName, customer.phone,
                                selectedButtonIndex, customer, null, context);
                          }).toList()
                        : admins.map((admin) {
                            return UserBody(admin.fullName, admin.phone,
                                selectedButtonIndex, null, admin, context);
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
}

Container UserBody(String name, String phone, int selectIndex,
    Customer? customer, User? user, BuildContext context) {
  return Container(
    width: double.infinity,
    height: 100,
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
    child: Padding(
      padding: const EdgeInsets.only(left: 25, right: 20, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                phone,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return InfoUser(
                  selectIndex: selectIndex,
                  customer: customer,
                  admin: user,
                );
              }));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              // foregroundColor: Colors.black,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(color: Colors.black),
              ),
              minimumSize: const Size(150, 43),
            ),
            child: const Text(
              'Xem chi tiết',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    ),
  );
}
