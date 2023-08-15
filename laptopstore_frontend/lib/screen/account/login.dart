import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../admin/mypage.dart';
import '../customer/home.dart';

class Login extends StatefulWidget {
  // final Future<List<User>> users;
  const Login({
    super.key,
    // required this.users
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorMessage = '';
  bool _showDialogSelectRole = false;
  var roleName;
  var user_id;

  Future<void> _login() async {
    final phone = phoneController.text;
    final password = passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Vui lòng điền đầy đủ thông tin đăng nhập.';
      });
      return;
    }
    Uri apiUrl = Uri.parse('http://10.0.2.2:8080/api/v1/account/login');

    final apiUrlWithParams = apiUrl.replace(queryParameters: {
      'phone': phone,
      'password': password,
    });

    try {
      final response = await http.get(apiUrlWithParams);

      if (response.statusCode == 200) {
        errorMessage = '';
        var responseData = json.decode(response.body);

        roleName = responseData['body']['role_name'];
        user_id = responseData['body']['user_id'];
        if (roleName.length > 1) {
          setState(() {
            _showDialogSelectRole = true;
          });
        } else {
          if (roleName[0] == 'CUSTOMER') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return CustomerHome(user_id: user_id, checkTab: 0);
            }));
          } else if (roleName[0] == 'ADMIN') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AdminHome(
                        userId: user_id,
                      )),
            );
          }
        }
        print(roleName);
        print(user_id);
      } else if (response.statusCode == 404) {
        setState(() {
          _showDialogSelectRole = false;
          errorMessage = 'Số điện thoại hoặc mật khẩu không đúng.';
        });
        print('Error: ${response.statusCode}');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  bool isValidPhoneNumber(String input) {
    const pattern = r'(^[0-9]{10,12}$)';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            const Text(
              'Đăng nhập',
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Số điện thoại',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              // onChanged: (value) => {textValue = value},
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Mật khẩu'),
            ),
            SizedBox(
              height: 30,
              child: errorMessage.isNotEmpty
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 15),
                      ),
                    )
                  : const SizedBox(),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: () async {
                    await _login();
                    if (_showDialogSelectRole) {
                      ShowDialogSelectRole(context);
                    }
                  },
                  child: const Text(
                    'ĐĂNG NHẬP',
                    style: TextStyle(fontSize: 17),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Future<dynamic> ShowDialogSelectRole(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng nhập với quyền'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 15.0,
              crossAxisSpacing: 15.0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List<Widget>.generate(roleName.length, (index) {
                return ElevatedButton(
                  onPressed: () {
                    String selectedRole = roleName[index];
                    print(roleName[index]);
                    Navigator.of(context).pop();

                    if (selectedRole == 'CUSTOMER') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => CustomerHome(
                                  user_id: user_id,
                                  checkTab: 0,
                                )),
                      );
                    } else if (selectedRole == 'ADMIN') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => AdminHome(
                                  userId: user_id,
                                )),
                      );
                    }
                  },
                  child: Text(roleName[index],
                      style: const TextStyle(fontSize: 18)),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
