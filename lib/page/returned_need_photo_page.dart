import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/scan_input.dart';

class ReturnedNeedPhotoPage extends StatefulWidget {
  const ReturnedNeedPhotoPage({Key? key}) : super(key: key);

  @override
  State<ReturnedNeedPhotoPage> createState() => _ReturnedNeedPhotoPageState();
}

class _ReturnedNeedPhotoPageState extends HiState<ReturnedNeedPhotoPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
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
        print("打开了待拍照列表: onResume");
        textEditingController.clear(); // 清除搜索栏
      } else if (widget == pre?.page || pre?.page is ReturnedNeedPhotoPage) {
        print("待拍照列表: onPause");
      }
    });
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Need Photo", "", () {}),
      body: Container(
        child: ListView(
          children: _buildWidget(),
        ),
      ),
    );
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
        title: Text("${element.shpmt_num},${element.order_num}"),
        subtitle: Text("${element.batch_num}"),
        trailing: const Icon(Icons.add_a_photo),
        onTap: () {
          HiNavigator.getInstance().onJumpTo(RouteStatus.returnedPhoto,
              args: {"needPhotoParce": element});
        },
      ));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    return widgets;
  }

  void loadData({shpmtNumCont = ""}) async {
    try {
      var result =
          await ReturnedDao.get(shpmtNumCont: shpmtNumCont, takePhoto: true);
      print('loadData():$result');
      if (result['status'] == "succ") {
        if (result['data'].length > 0) {
          setState(() {
            parcelList.clear();
            for (var item in result['data']) {
              parcelList.add(ReturnedParcel.fromJson(item));
            }
            _isLoading = false;
          });
        } else {
          showWarnToast("No Returned Parcel Need To Photoed");
        }
      } else {
        print(result['reason']);
        showWarnToast(result['reason'].join(","));
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
    textEditingController.clear(); // 清除搜索栏
    FocusScope.of(context).requestFocus(focusNode); //聚焦
  }

  @override
  bool get wantKeepAlive => true;
}