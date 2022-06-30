import 'package:flutter/material.dart';
import 'package:wms_app/db/hi_cache.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/home_appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
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
      appBar: homeAppBar("Welcome"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                  onTap: () {
                    HiNavigator.getInstance()
                        .onJumpTo(RouteStatus.returnedPage);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      children: const [
                        Image(
                          image: AssetImage('images/service.png'),
                        ),
                        Text(
                          "Returned",
                          style: TextStyle(fontSize: 22),
                        )
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () {
                    showWarnToast("Undeveloped");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      children: const [
                        Image(
                          image: AssetImage('images/inbound.png'),
                        ),
                        Text(
                          "Inbound",
                          style: TextStyle(fontSize: 22),
                        )
                      ],
                    ),
                  ))
            ],
          ),
          const Divider(
            height: 20,
            color: Colors.transparent,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                  onTap: () {
                    showWarnToast("Undeveloped");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      children: const [
                        Image(
                          image: AssetImage('images/outbound.png'),
                        ),
                        Text(
                          "Outbound",
                          style: TextStyle(fontSize: 22),
                        )
                      ],
                    ),
                  )),
              InkWell(
                  onTap: () {
                    showWarnToast("Undeveloped");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      children: const [
                        Image(
                          image: AssetImage('images/inventory.png'),
                        ),
                        Text(
                          "Inventory",
                          style: TextStyle(fontSize: 22),
                        )
                      ],
                    ),
                  ))
            ],
          )
        ]),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
