import 'package:flutter/material.dart';
import 'package:wms_app/http/core/hi_error.dart';
import 'package:wms_app/http/dao/login_dao.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/login_button.dart';
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
        appBar: appBar("Login", "", (() {
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
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: LoginButton(
                  'Login',
                  enable: loginEnable,
                  onPressed: send,
                ),
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

  void send() async {
    dynamic result;
    try {
      result = await LoginDao.getToken(userName!, password!);
      if (result[LoginDao.TOKEN] != null) {
        print("login successful");
        print(result[LoginDao.TOKEN]);
        await LoginDao.getAccountInfo(result[LoginDao.TOKEN]);
      } else {
        print("login fail");
      }
    } catch (e) {
      print(e);
    }
  }
}
