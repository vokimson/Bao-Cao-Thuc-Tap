// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:storelaptop/screen/admin/mypage_manage_user.dart';
import 'package:storelaptop/screen/admin/mypage_update.dart';

import '../../home.dart';
import '../../model/user.dart';
import '../customer/mypage.dart';
import 'package:http/http.dart' as http;

class AdminHome extends StatefulWidget {
  int userId;
  AdminHome({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHome();
}

class _AdminHome extends State<AdminHome> {
  int userId = 0;

  User user = User(
      userId: 0,
      email: '',
      password: '',
      fullName: '',
      dateOfBirth: '',
      phone: '',
      address: '',
      customerId: 0);
  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    awaitInfo();
  }

  Future<void> awaitInfo() async {
    User user1 = await fetchUserInfo(userId);
    setState(() {
      user = user1;
    });
  }

  Future<User> fetchUserInfo(int userId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/user/getInfoUserById');
    final apiUrlWithParams =
        url.replace(queryParameters: {'user_id': userId.toString()});
    try {
      final response = await http.get(apiUrlWithParams);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'].isNotEmpty) {
          User user = User.fromJson(data['body'][0]);
          print('Fet Cus: ${user.phone}');
          return user;
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
    return User(
        userId: 0,
        email: '',
        password: '',
        fullName: '',
        dateOfBirth: '',
        phone: '',
        address: '',
        customerId: 0);
  }

  @override
  Widget build(BuildContext context) {
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                          fontSize: 45, fontWeight: FontWeight.bold),
                    ),
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                        user.phone,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyMyPage('Quản lý thông tin người dùng', '', () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageUser(),
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
                              content: const Text(
                                  'Bạn có chắc chắn muốn đăng xuất?'),
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
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
