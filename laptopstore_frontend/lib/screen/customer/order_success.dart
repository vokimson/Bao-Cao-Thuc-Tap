// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'home.dart';

class OrderSuccess extends StatelessWidget {
  final int user_id;
  const OrderSuccess({
    Key? key,
    required this.user_id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
            ),
            SizedBox(
              width: 220,
              height: 220,
              child: Image.asset(
                'assets/order_success.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Đặt hàng thành công!',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Đơn hàng của bạn sẽ được giao đến sớm.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const Text(
              'Cảm ơn bạn đã chọn ứng dụng của chúng tôi!',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber),
                  minimumSize: MaterialStateProperty.all(const Size(
                      double.infinity,
                      50)), // Định nghĩa kích thước tối thiểu của nút
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          30), // Định nghĩa bán kính bo góc
                    ),
                  ),
                ),
                onPressed: () {
                  // int userId = CustomerHome.getUserId(context);
                  // print('User ID:: $userId');
                  // Navigator.pop(context);
                  print('UserID OS: $user_id');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => CustomerHome(
                              user_id: user_id,
                              checkTab: 0,
                            )),
                  );
                },
                child: const Text(
                  'Tiếp tục mua hàng',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
