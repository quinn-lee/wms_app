import 'package:flutter/material.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/widget/home_appbar.dart';

class ReturnedPage extends StatefulWidget {
  const ReturnedPage({Key? key}) : super(key: key);

  @override
  State<ReturnedPage> createState() => _ReturnedPageState();
}

class _ReturnedPageState extends State<ReturnedPage>
    with AutomaticKeepAliveClientMixin {
  var listener;

  @override
  void initState() {
    super.initState();
    HiNavigator.getInstance().addListener(listener = (current, pre) {
      print("current: ${current.page}");
      print("pre: ${pre.page}");
      if (widget == current.page || current.page is ReturnedPage) {
        print("打开了Returned: onResume");
      } else if (widget == pre?.page || pre?.page is ReturnedPage) {
        print("Returned: onPause");
      }
    });
    ReturnedDao.get(shpmtNumCont: "", takePhoto: true);
  }

  @override
  void dispose() {
    HiNavigator.getInstance().removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: homeAppBar("Returned"),
        body: Container(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.scanner),
                title: const Text("Register Returned Parcels"),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  HiNavigator.getInstance().onJumpTo(RouteStatus.returnedScan);
                },
              ),
              ListTile(
                leading: const Icon(Icons.scanner),
                title: const Text("Photo"),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  HiNavigator.getInstance().onJumpTo(RouteStatus.returnedPhoto);
                },
              ),
            ],
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
