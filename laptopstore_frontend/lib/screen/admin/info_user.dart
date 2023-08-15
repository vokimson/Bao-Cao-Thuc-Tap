// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../model/customer.dart';
import '../../model/user.dart';

class InfoUser extends StatefulWidget {
  int selectIndex;
  Customer? customer;
  User? admin;
  InfoUser({
    Key? key,
    required this.selectIndex,
    required this.customer,
    required this.admin,
  }) : super(key: key);

  @override
  State<InfoUser> createState() => _InfoUserState();
}

class _InfoUserState extends State<InfoUser> {
  late Customer? customer;
  late User? admin;
  int selectIndex = 0;
  @override
  void initState() {
    super.initState();
    customer = widget.customer;
    admin = widget.admin;
    selectIndex = widget.selectIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Thông tin người dùng',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    if (selectIndex == 0)
                      Column(
                        children: [
                          Text(
                            customer?.fullName ?? '',
                            style: const TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Text(
                            admin?.fullName ?? '',
                            style: const TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                          // Opacity(
                          //   opacity: 0.5,
                          //   child: Text(
                          //     admin?.phone ?? '',
                          //     style: const TextStyle(fontSize: 18),
                          //   ),
                          // ),
                        ],
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.maxFinite,
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
                    padding: const EdgeInsets.all(15),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        if (selectIndex == 0)
                          Column(
                            children: [
                              InfoBody('Số điện thoại:',
                                  customer?.phone.toString() ?? ''),
                              InfoBody('Ngày sinh:',
                                  customer?.dateOfBirth?.toString() ?? ''),
                              InfoBody(
                                  'Email:', customer?.email?.toString() ?? ''),
                              InfoBody('Địa chỉ:',
                                  customer?.address?.toString() ?? ''),
                              // if (customer?.tax_code != '' ||
                              //     customer?.tax_code != null)
                              if (customer?.customerId != 0)
                                InfoBody(
                                    'Mã số thuế:', customer?.tax_code ?? ''),
                            ],
                          )
                        else
                          Column(
                            children: [
                              InfoBody('Số điện thoại:',
                                  admin?.phone.toString() ?? ''),
                              InfoBody('Ngày sinh:',
                                  admin?.dateOfBirth?.toString() ?? ''),
                              InfoBody(
                                  'Email:', admin?.email?.toString() ?? ''),
                              InfoBody(
                                  'Địa chỉ:', admin?.address?.toString() ?? ''),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Padding InfoBody(String left, String right) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(left,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      )),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 230),
                      child: Text(
                        right,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        maxLines: null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    ),
  );
}
