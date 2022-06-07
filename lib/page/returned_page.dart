import 'package:flutter/material.dart';
import 'package:wms_app/navigator/hi_navigator.dart';

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
        child: Text('退运包裹'),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
