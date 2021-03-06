import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/db/hi_cache.dart';

import 'package:wms_app/http/dao/login_dao.dart';
// import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/login_input.dart';

import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/widget/login_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends HiState<LoginPage> {
  final TextEditingController emailEditingController = TextEditingController();
  final TextEditingController passwdEditingController = TextEditingController();
  bool protect = false;
  bool loginEnable = false;
  String? userName;
  String? password;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 登录时记住email
    if (HiCache.getInstance().get("login_email") != null) {
      userName = HiCache.getInstance().get("login_email");
      emailEditingController.text = HiCache.getInstance().get("login_email");
    }
  }

  @override
  void dispose() {
    emailEditingController.dispose();
    passwdEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Login", "", (() {
          print("right button click.");
        })),
        body: LoadingContainer(
          cover: true,
          isLoading: _isLoading,
          child: ListView(
            children: [
              const Divider(
                height: 15,
                color: Colors.transparent,
              ),
              const LoginLogo(),
              const Divider(
                height: 15,
                color: Colors.transparent,
              ),
              LoginInput(
                'Email',
                'Please input email',
                emailEditingController,
                onChanged: (text) {
                  userName = text;
                  checkInput();
                },
                focusChanged: (bool hasFocus) {
                  if (!hasFocus) {
                    checkInput();
                  }
                },
              ),
              LoginInput(
                'Password',
                'Please input password',
                passwdEditingController,
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
                  1,
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
    setState(() {
      loginEnable = false; //不能重复点击登录
      _isLoading = true;
    });
    try {
      result = await LoginDao.getToken(userName!, password!);
      if (result[LoginDao.TOKEN] != null) {
        setState(() {
          _isLoading = false;
        });
        print("login successful");
        showToast("Login Successful");
        HiNavigator.getInstance().onJumpTo(RouteStatus.home);
        // 暂时不需要获取用户信息
        // await LoginDao.getAccountInfo(result[LoginDao.TOKEN]);
      } else {
        setState(() {
          _isLoading = false;
        });
        print("login fail");
        showWarnToast(result['error']);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      showWarnToast(e.toString());
    }
  }
}
