import 'package:flutter/material.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/navigator/hi_navigator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var listener;

  @override
  void initState() {
    super.initState();
    HiNavigator.getInstance().addListener(listener = (current, pre) {
      print("current: ${current.page}");
      print("pre: ${pre.page}");
      if (widget == current.page || current.page is HomePage) {
        print("打开了首页: onResume");
      } else if (widget == pre?.page || pre?.page is HomePage) {
        print("首页: onPause");
      }
    });
  }

  @override
  void dispose() {
    HiNavigator.getInstance().removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          child: Column(
            children: [
              const Text("首页"),
              MaterialButton(
                  onPressed: () => HiNavigator.getInstance().onJumpTo(
                      RouteStatus.detail,
                      args: {"rparcel": ReturnedParcel(222)}),
                  child: const Text("详情"))
            ],
          ),
        ));
  }
}
