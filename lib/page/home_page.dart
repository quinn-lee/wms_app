import 'package:flutter/material.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/navigator/hi_navigator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
