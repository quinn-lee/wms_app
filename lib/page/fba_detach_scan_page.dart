import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/fba_detach_dao.dart';
import 'package:wms_app/model/fba_detach_parcel.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/scan_input.dart';

class FbaDetachScanPage extends StatefulWidget {
  const FbaDetachScanPage({Key? key}) : super(key: key);

  @override
  State<FbaDetachScanPage> createState() => _FbaDetachScanPageState();
}

class _FbaDetachScanPageState extends HiState<FbaDetachScanPage> {
  List<FbaDetachParcel> parcelList = [];
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? num;
  bool _isLoading = false;
  bool scanFlag = false;
  AudioCache player = AudioCache();

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Fba Detach", "", () {}),
        body: LoadingContainer(
          cover: true,
          isLoading: _isLoading,
          child: ListView(
            children: _buildWidget(),
          ),
        ));
  }

  List<Widget> _buildWidget() {
    List<Widget> widgets = [];
    widgets.add(ScanInput(
      "Shipment No",
      "Scan Fba Detach parcel's shipment no",
      focusNode,
      textEditingController,
      onChanged: (text) {
        num = text;
      },
      onSubmitted: (text) {
        loadData();
      },
    ));
    widgets.add(const Divider(
      height: 1,
      color: Colors.white,
    ));
    for (var element in parcelList) {
      widgets.add(ListTile(
        title: Text("${element.identifier}, ${element.account ?? ''}"),
        subtitle: Text(element.updatedAt!.substring(0, 10)),
        trailing: const Icon(Icons.navigate_next),
        onTap: () {
          HiNavigator.getInstance().onJumpTo(RouteStatus.fbaDetachScanSku,
              args: {"fbaDetachParcel": element});
        },
      ));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    if (scanFlag) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: LoginButton(
          parcelList.isEmpty
              ? 'No History Parcel, New Parcel?'
              : 'New Another Parcel',
          1,
          enable: true,
          onPressed: newParcel,
        ),
      ));
    }
    return widgets;
  }

  void loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      dynamic result;
      if (num != null && num != "") {
        result = await FbaDetachDao.search(num!);
      } else {
        setState(() {
          _isLoading = false;
        });
        showWarnToast("Please scan shipment num!");
      }
      if (result['status'] == "succ") {
        setState(() {
          parcelList.clear();
          for (var item in result['data']) {
            parcelList.add(FbaDetachParcel.fromJson(item));
          }
          _isLoading = false;
          scanFlag = true;
        });
      } else {
        showWarnToast(result['reason'].join(","));
        setState(() {
          _isLoading = false;
          parcelList.clear();
        });
      }
    } catch (e) {
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
        parcelList.clear();
      });
    }
    if (mounted) {
      // textEditingController.clear(); // 清除搜索栏
      // FocusScope.of(context).requestFocus(focusNode); //聚焦
    }
  }

  void newParcel() async {
    setState(() {
      _isLoading = true;
    });
    try {
      dynamic result;
      if (num != null && num != "") {
        result = await FbaDetachDao.newIdentifier(num!);
      } else {
        showWarnToast("Please scan shipment num!");
      }
      if (result['status'] == "succ") {
        setState(() {
          _isLoading = false;
          parcelList.clear();
          player.play('sounds/success01.mp3');
          FbaDetachParcel fdp = FbaDetachParcel.fromJson(result['data']);
          HiNavigator.getInstance().onJumpTo(RouteStatus.fbaDetachScanSku,
              args: {"fbaDetachParcel": fdp});
        });
      } else {
        showWarnToast(result['reason'].join(","));
        player.play('sounds/alert.mp3');
        setState(() {
          _isLoading = false;
          parcelList.clear();
        });
      }
    } catch (e) {
      showWarnToast(e.toString());
      player.play('sounds/alert.mp3');
      setState(() {
        _isLoading = false;
        parcelList.clear();
      });
    }
  }
}
