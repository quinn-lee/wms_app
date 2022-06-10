import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/page/returned_need_photo_page.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/scan_input.dart';

class ReturnedNeedProcessPage extends StatefulWidget {
  const ReturnedNeedProcessPage({Key? key}) : super(key: key);

  @override
  State<ReturnedNeedProcessPage> createState() =>
      _ReturnedNeedProcessPageState();
}

class _ReturnedNeedProcessPageState extends HiState<ReturnedNeedProcessPage> {
  List<ReturnedParcel> parcelList = [];
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? num;
  bool _isLoading = true;
  var listener;

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() {
      print("controller: ${textEditingController.text}");
    });
    HiNavigator.getInstance().addListener(listener = (current, pre) {
      print("current: ${current.page}");
      print("pre: ${pre.page}");
      if (widget == current.page || current.page is ReturnedNeedPhotoPage) {
        print("打开了待处理列表: onResume");
        textEditingController.clear(); // 清除搜索栏
        loadData(); // 重新加载数据
      } else if (widget == pre?.page || pre?.page is ReturnedNeedPhotoPage) {
        print("待处理列表: onPause");
      }
    });
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Need To Be Processed Parcels", "", () {}),
        body: LoadingContainer(
          cover: true,
          isLoading: _isLoading,
          child: Container(
            child: ListView(
              children: _buildWidget(),
            ),
          ),
        ));
  }

  List<Widget> _buildWidget() {
    List<Widget> widgets = [];
    widgets.add(ScanInput(
      "Barcode",
      "Scan Reterned parcel's barcode",
      focusNode,
      textEditingController,
      onChanged: (text) {
        num = text;
        print("num: $num");
      },
      onSubmitted: (text) {
        loadData(shpmtNumCont: num);
      },
      focusChanged: (bool hasFocus) {
        if (!hasFocus) {}
      },
    ));
    widgets.add(const Divider(
      height: 1,
      color: Colors.white,
    ));
    for (var element in parcelList) {
      widgets.add(ListTile(
        title: Text("${element.shpmt_num}, ${element.order_num}"),
        subtitle: Text("${element.batch_num}"),
        trailing: _tools(),
        // onTap: () {
        //   HiNavigator.getInstance().onJumpTo(RouteStatus.returnedPhoto,
        //       args: {"needPhotoParce": element});
        // },
      ));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    return widgets;
  }

  List<PopupMenuEntry<String>> _toolMenuItems(BuildContext context) {
    List toolModels = ["a", "b"];
    return toolModels.map<PopupMenuEntry<String>>((title) {
      return PopupMenuItem<String>(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
        ),
        value: title,
        child: Row(
          children: [
            const SizedBox(
              width: 4,
            ),
            Text(
              title,
            )
          ],
        ),
      );
    }).toList();
  }

  Widget _tools() {
    return PopupMenuButton<String>(
      itemBuilder: _toolMenuItems,
      onSelected: (String value) {
        print(value);
      },
      icon: const Icon(
        Icons.more_horiz,
        color: Colors.white,
      ),
    );
  }

  void loadData({shpmtNumCont = ""}) async {
    try {
      var result = await ReturnedDao.get(
          shpmtNumCont: shpmtNumCont, status: "in_process_photo");
      print('loadData():$result');
      if (result['status'] == "succ") {
        setState(() {
          parcelList.clear();
          for (var item in result['data']) {
            parcelList.add(ReturnedParcel.fromJson(item));
          }
          _isLoading = false;
        });
        if (result['data'].length == 0) {
          showWarnToast("No Returned Parcel Need To Be Processed");
        }
      } else {
        print(result['reason']);
        showWarnToast(result['reason'].join(","));
        setState(() {
          _isLoading = false;
          parcelList.clear();
        });
      }
    } catch (e) {
      print(e);
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
        parcelList.clear();
      });
    }
    if (mounted) {
      textEditingController.clear(); // 清除搜索栏
      FocusScope.of(context).requestFocus(focusNode); //聚焦
    }
  }

  @override
  bool get wantKeepAlive => true;
}
