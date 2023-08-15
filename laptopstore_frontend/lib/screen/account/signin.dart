import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();

  String errorMessage = '';
  bool showSuccessDialog = false;

  Future<bool> _signin() async {
    String phone = phoneController.text;
    String password = passwordController.text;
    String fullname = fullnameController.text;
    if (phone.isEmpty || password.isEmpty || fullname.isEmpty) {
      setState(() {
        errorMessage = 'Vui lòng điền đầy đủ thông tin đăng ký.';
      });
      return false;
    }
    if (isValidPhoneNumber(phone) == false) {
      setState(() {
        errorMessage = 'Số điện thoại không hợp lệ!';
      });
      return false;
    }
    if (isValidName(fullname) == false) {
      setState(() {
        errorMessage = 'Họ tên không hợp lệ!';
      });
      return false;
    }

    if (password.length < 6) {
      setState(() {
        errorMessage = 'Mật khẩu phải từ 6 ký tự trở lên.';
      });
      return false;
    }

    Uri apiUrl = Uri.parse('http://10.0.2.2:8080/api/v1/account/signup/');

    var body = {
      'phone': phone,
      'password': password,
      'fullname': fullname,
      'role_name': 'customer',
    };
    print(phone);
    try {
      var response = await http.post(apiUrl, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        int success = data['body'][0][0]['success'];
        print(success);
        if (success == 1) {
          setState(() {
            errorMessage = '';
          });
          print('đăng ký thành công');
          return true;
        } else {
          setState(() {
            errorMessage = 'Tài khoản đã tồn tại.';
          });
          print(errorMessage);
          return false;
        }
      } else {
        print('Error Signup: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    return false;
  }

  bool isValidPhoneNumber(String input) {
    const pattern = r'^0[0-9]{9,11}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(input);
  }

  bool isValidName(String input) {
    const pattern = r'^[a-zA-ZÀ-ỹ ]+$';
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
              'Đăng ký',
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
              obscureText: true,
              controller: passwordController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Mật khẩu'),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: fullnameController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-ZÀ-ỹ ]+$')),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Họ tên',
              ),
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
                    if (await _signin()) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Thành công'),
                            content: const Text('Đăng ký thành công.'),
                            actions: [
                              TextButton(
                                child: const Text('Đăng nhập'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return const Login();
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text(
                    'ĐĂNG KÝ',
                    style: TextStyle(fontSize: 17),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
