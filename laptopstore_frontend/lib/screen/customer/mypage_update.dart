// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import '../../model/user.dart';

class MyPageUpdate extends StatefulWidget {
  int userId;
  MyPageUpdate({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<MyPageUpdate> createState() => _MyPageUpdateState();
}

class _MyPageUpdateState extends State<MyPageUpdate> {
  var _date;
  int userId = 0;
  // bool isEditMode = false;
  bool checkPass = true;
  String errorPass = '';

  TextEditingController fullnameController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController taxController = TextEditingController();

  TextEditingController oldPassController = TextEditingController();
  TextEditingController newPassController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  // TextEditingController controller = TextEditingController();

  bool _showErrorFullName = false;
  bool _showErrorPhone = false;
  bool _showErrorEmail = false;
  bool _showErrorOldPass = false;
  bool _showErrorNewPass = false;
  bool _showErrorConfirmPass = false;

  User user = User(
    userId: 0,
    email: '',
    password: '',
    fullName: '',
    dateOfBirth: '', // Milliseconds since epoch (Unix timestamp)
    phone: '',
    address: '',
    customerId: 0,
  );

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    // fetchUserInfo(user.userId);
    getUserInfo();
    // getUserInfo();
  }

  void getUserInfo() async {
    User userInfo = await fetchUserInfo(userId);
    String taxCode = await fetchGetTaxCustomer(userId);

    setState(() {
      user = userInfo;

      final date = user.dateOfBirth ?? '';
      if (date != '') {
        dateOfBirthController.text = user.dateOfBirth ?? '';
      }
      taxController.text = taxCode.toString();
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
        final body = data['body'][0];
        if (body != null) {
          fullnameController.text = body['full_name'] ?? '';
          phoneController.text = body['phone'] ?? '';
          emailController.text = body['email'] ?? '';
          addressController.text = body['address'] ?? '';

          return User.fromJson(body);
        } else {
          print('Không tìm thấy dữ liệu');
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
      customerId: 0,
    );
  }

  Future<String> fetchGetTaxCustomer(int userId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/v1/user/getTaxOfCustomer');
    final apiUrlWithParams =
        url.replace(queryParameters: {'user_id': userId.toString()});
    try {
      final response = await http.get(apiUrlWithParams);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['body'].isNotEmpty) {
          final tax = data['body'][0]['tax_code'] ?? '';
          return tax;
        } else {
          print('Data not found');
        }
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print('Lỗi fetchGetTaxCustomer');
      print('Error: $e');
    }
    return '';
  }

  Future<bool> fetchUpdateUserInfo() async {
    String apiUrl = 'http://10.0.2.2:8080/api/v1/user/updateUserInfo';
    print('ADDRESS123: ${addressController.text}');
    try {
      var response = await http.put(
        Uri.parse(apiUrl),
        body: {
          'user_id': user.userId.toString(),
          'full_name': fullnameController.text ?? '',
          'date_of_birth': dateOfBirthController.text ?? '',
          'phone': phoneController.text ?? '',
          'email': emailController.text ?? '',
          'address': addressController.text ?? '',
          'tax': taxController.text ?? '',
          // 'tax': taxValue != null ? taxValue.toString() : '',
        },
      );

      if (response.statusCode == 200) {
        print('Update user success');

        return true;
      } else {
        print('Update User Info Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Cập nhật thông tin',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin tài khoản',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFieldMethod(
                    fullnameController,
                    'Họ tên',
                    _showErrorFullName,
                    null,
                    'Vui lòng nhập thông tin của bạn'),
                const SizedBox(height: 15),
                TextFieldMethod(phoneController, 'Số điện thoại',
                    _showErrorPhone, null, 'Vui lòng nhập thông tin của bạn'),
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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 16),
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
                          _date = "${date.year}-${date.month}-${date.day}";
                          dateOfBirthController.text = _date;
                        });
                      }
                    });
                  },
                ),
                const SizedBox(height: 15),
                TextFieldMethod(emailController, 'Email', _showErrorEmail, null,
                    'Email không hợp lệ'),
                const SizedBox(height: 15),
                TextFieldMethod(addressController, 'Địa chỉ', null, null, null),
                const SizedBox(height: 15),
                TextFieldMethod(
                    taxController, 'Mã số thuế (nếu có)', null, null, null),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFFFFA013)),
                    minimumSize: MaterialStateProperty.all(
                        const Size(double.infinity, 50)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  onPressed: () {
                    _validateFields();
                    // showAlertDialog(context);
                  },
                  child: const Text(
                    'Lưu',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Đổi mật khẩu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldMethod(oldPassController, 'Mật khẩu cũ',
                    _showErrorOldPass, true, 'Vui lòng nhập thông tin của bạn'),
                const SizedBox(height: 15),
                TextFieldMethod(newPassController, 'Mật khẩu mới',
                    _showErrorNewPass, true, 'Vui lòng nhập thông tin của bạn'),
                const SizedBox(height: 15),
                TextFieldMethod(
                    confirmPassController,
                    'Xác nhận mật khẩu',
                    _showErrorConfirmPass,
                    true,
                    'Vui lòng nhập thông tin của bạn'),
                SizedBox(
                  height: 25,
                  child: errorPass.isEmpty
                      ? null
                      : Text(
                          errorPass,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 15),
                        ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFFFFA013)),
                    minimumSize: MaterialStateProperty.all(
                        const Size(double.infinity, 50)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (newPassController.text.length < 6) {
                      setState(() {
                        errorPass = 'Mật khẩu phải tử 6 ký tự trở lên.';
                      });
                    } else {
                      setState(() {
                        _validatePasswordFields();
                      });
                    }

                    // showAlertDialog(context);
                  },
                  child: const Text(
                    'Lưu',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> _validateFields() async {
    setState(() {
      _showErrorFullName = fullnameController.text.isEmpty;
      _showErrorPhone = phoneController.text.isEmpty;
    });
    final checkEmail = isEmailValid(emailController.text);
    if (checkEmail == false) {
      setState(() {
        _showErrorEmail = true;
      });
    }
    if (!_showErrorFullName && !_showErrorPhone && !_showErrorEmail) {
      if (await fetchUpdateUserInfo()) {
        // setState(() {
        //   fetchUserInfo(widget.user.userId);
        // });
        user.fullName = fullnameController.text;
        user.phone = phoneController.text;
        user.dateOfBirth = dateOfBirthController.text;
        user.email = emailController.text;
        user.address = addressController.text;

        showAlertDialog(context, 'Cập nhật thành công',
            'Thông tin của bạn đã được cập nhật.');
      }

      print('Full Name: ${fullnameController.text}');
      print('Date of Birth: ${dateOfBirthController.text}');
      print('Phone: ${phoneController.text}');
      print('Email: ${emailController.text}');
      print('Address: ${addressController.text}');
      print('Tax: ${taxController.text}');
    }
  }

  Future<void> _validatePasswordFields() async {
    setState(() {
      _showErrorOldPass = oldPassController.text.isEmpty;
      _showErrorNewPass = newPassController.text.isEmpty;
      _showErrorConfirmPass = confirmPassController.text.isEmpty;
    });

    if (!_showErrorOldPass && !_showErrorNewPass && !_showErrorConfirmPass) {
      if (oldPassController.text != user.password) {
        setState(() {
          errorPass = 'Mật khẩu cũ không đúng!';
        });
      } else if (newPassController.text != confirmPassController.text) {
        setState(() {
          errorPass = 'Mật khẩu mới và xác nhận mật khẩu không khớp.';
        });
      } else {
        if (await fetchUpdateUserPassword(userId, confirmPassController.text)) {
          user.password = confirmPassController.text;
          setState(() {
            errorPass = '';
            oldPassController.text = '';
            newPassController.text = '';
            confirmPassController.text = '';
          });
          showAlertDialog(context, 'Cập nhật thành công',
              'Thông tin của bạn đã được cập nhật.');
        }
      }

      print('Old Password: ${oldPassController.text}');
      print('New Password: ${newPassController.text}');
      print('Confirm Password: ${confirmPassController.text}');
    }
  }
}

//'Vui lòng nhập thông tin của bạn'
TextField TextFieldMethod(
    TextEditingController textEditingController,
    String hintText,
    bool? showError,
    bool? checkEditPass,
    String? messageError) {
  return TextField(
    obscureText: checkEditPass ?? false ? true : false,
    // enabled: isEditMode,
    controller: textEditingController,
    style: const TextStyle(fontSize: 18),
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
      // hintText: hintText,
      labelText: hintText,
      errorText: showError ?? false ? messageError : null,
      errorStyle: const TextStyle(fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
    ),
  );
}

Future<bool> fetchUpdateUserPassword(int userId, String password) async {
  String apiUrl = 'http://10.0.2.2:8080/api/v1/account/changePassword';

  try {
    var response = await http.put(
      Uri.parse(apiUrl),
      body: {
        'user_id': userId.toString(),
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      print('Update password success');

      return true;
    } else {
      print('Update User Password Error: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}

void showAlertDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              FocusScope.of(context).unfocus();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

bool isEmailValid(String email) {
  if (email.isNotEmpty) {
    final isValid = EmailValidator.validate(email);
    return isValid;
  }
  return true;
}
