import 'package:flutter/material.dart';

import '../customer/mypage_update.dart';
import 'package:http/http.dart' as http;

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  int selectedButtonIndex = 0;
  String errorPass = '';

  TextEditingController fullnameController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController taxController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _showErrorFullName = false;
  bool _showErrorPhone = false;
  final bool _showErrorPass = false;

  Future<bool> fetchAdminCreateUser(String roleName) async {
    String apiUrl = 'http://10.0.2.2:8080/api/v1/admin/AdminCreateUser';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'phone': phoneController.text,
          'full_name': fullnameController.text,
          'date_of_birth': dateOfBirthController.text ?? '',
          'email': emailController.text ?? '',
          'address': addressController.text ?? '',
          'password': passwordController.text,
          'role_name': roleName,
          // 'tax': taxValue != null ? taxValue.toString() : '',
        },
      );

      if (response.statusCode == 200) {
        print('AdminCreateUser success');

        return true;
      } else {
        print('fetchAdminCreateUser Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Tạo tài khoản mới',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
                    ButtonMethod(0, 'Khách hàng', () async {
                      setState(() {
                        selectedButtonIndex = 0;
                        _showErrorFullName = false;
                        _showErrorPhone = false;
                        errorPass = '';
                        emptyText();
                      });
                    }),
                    ButtonMethod(1, 'Quản lý', () async {
                      setState(() {
                        selectedButtonIndex = 1;
                        _showErrorFullName = false;
                        _showErrorPhone = false;
                        errorPass = '';
                        emptyText();
                      });
                    }),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  'Thông tin tài khoản',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    children: [
                      TextFieldMethod(fullnameController, 'Họ tên',
                          _showErrorFullName, null,'Vui lòng nhập thông tin của bạn'),
                      const SizedBox(height: 15),
                      TextFieldMethod(phoneController, 'Số điện thoại',
                          _showErrorPhone, null,'Vui lòng nhập thông tin của bạn'),
                      const SizedBox(height: 15),
                      TextField(
                        controller: dateOfBirthController,
                        style: const TextStyle(fontSize: 18),
                        // enabled: isEditMode,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintText: 'Ngày sinh',
                          labelText: 'Ngày sinh',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 16),
                        ),
                        onTap: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          ).then((date) {
                            if (date != null) {
                              setState(() {
                                String date1 =
                                    "${date.year}-${date.month}-${date.day}";
                                dateOfBirthController.text = date1;
                              });
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFieldMethod(emailController, 'Email', null, null,null),
                      const SizedBox(height: 15),
                      TextFieldMethod(addressController, 'Địa chỉ', null, null,null),
                      const SizedBox(height: 15),
                      TextFieldMethod(
                          passwordController, 'Mật khẩu', _showErrorPass, true, 'Vui lòng nhập thông tin của bạn'),
                      SizedBox(
                        height: 25,
                        child: errorPass.isEmpty
                            ? null
                            : Text(
                                errorPass,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 15),
                              ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color(0xFFFFA013)),
                          minimumSize: MaterialStateProperty.all(
                              const Size(double.infinity, 50)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _validateFields();
                          });
                        },
                        child: const Text(
                          'Tạo tài khoản',
                          style: TextStyle(fontSize: 20),
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
    );
  }

  Future<void> _validateFields() async {
    setState(() {
      _showErrorFullName = fullnameController.text.isEmpty;
      _showErrorPhone = phoneController.text.isEmpty;
      if (passwordController.text.length < 6) {
        setState(() {
          errorPass = 'Mật khẩu phải tử 6 ký tự trở lên.';
        });
      }
    });

    if (!_showErrorFullName && !_showErrorPhone && errorPass.isEmpty) {
      if (selectedButtonIndex == 0) {
        if (await fetchAdminCreateUser('customer')) {
          showAlertDialog(context, 'Tạo tài khoản thành công',
              'Tài khoản mới đã được tạo thành công.');
        }
      } else {
        if (await fetchAdminCreateUser('admin')) {
          showAlertDialog(context, 'Tạo tài khoản thành công',
              'Tài khoản mới đã được tạo thành công.');
        }
      }
      emptyText();
    }
  }

  void emptyText() {
    fullnameController.text = '';
    phoneController.text = '';
    dateOfBirthController.text = '';
    emailController.text = '';
    addressController.text = '';
    passwordController.text = '';
  }
}
