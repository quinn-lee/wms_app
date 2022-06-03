import 'package:flutter/material.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/login_input.dart';

import 'package:wms_app/util/string_util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool protect = false;
  bool loginEnable = false;
  String? userName;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("登录", "", (() {
          print("right button click.");
        })),
        body: Container(
          child: ListView(
            children: [
              LoginInput(
                'Email',
                'Please input email',
                onChanged: (text) {
                  userName = text;
                  checkInput();
                },
              ),
              LoginInput(
                'Password',
                'Please input password',
                obscureText: true,
                onChanged: (text) {
                  password = text;
                  checkInput();
                },
                focusChanged: (focus) {
                  setState(() {
                    protect = focus;
                  });
                },
              )
            ],
          ),
        ));
  }

  void checkInput() {
    bool enable;
    if (isNotEmpty(userName) && isNotEmpty(password)) {
      enable = true;
    } else {
      enable = false;
    }
    setState(() {
      loginEnable = enable;
    });
  }
}
