import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wms_app/util/color.dart';
import 'package:wms_app/util/string_util.dart';
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

class _ReturnedNeedProcessPageState extends HiState<ReturnedNeedProcessPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  List<ReturnedParcel> parcelList = [];
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? num;
  bool _isLoading = true;
  AudioCache player = AudioCache();
  var listener;

  @override
  void initState() {
    bool resumeFlag = false;
    super.initState();
    textEditingController.addListener(() {
      // print("controller: ${textEditingController.text}");
    });
    HiNavigator.getInstance().addListener(listener = (current, pre) {
      // print("current: ${current.page}");
      // print("pre: ${pre.page}");
      if (widget == current.page || current.page is ReturnedNeedProcessPage) {
        // print("打开了待处理列表: onResume");
        textEditingController.clear(); // 清除搜索栏
        loadData(); // 重新加载数据
        resumeFlag = true;
      } else if (widget == pre?.page || pre?.page is ReturnedNeedProcessPage) {
        // print("待处理列表: onPause");
      }
    });
    if (!resumeFlag) {
      loadData();
    }
  }

  @override
  void dispose() {
    HiNavigator.getInstance().removeListener(listener);
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
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
      "Shipment No",
      "Scan Returned parcel's shipment no",
      focusNode,
      textEditingController,
      onChanged: (text) {
        num = text;
        // print("num: $num");
      },
      onSubmitted: (text) {
        loadData(shpmtNumCont: num);
      },
      // focusChanged: (bool hasFocus) {
      //   if (!hasFocus) {}
      // },
    ));
    widgets.add(const Divider(
      height: 1,
      color: Colors.white,
    ));
    for (var element in parcelList) {
      widgets.add(ListTile(
        title: Text("${element.shpmtNum}, ${element.roNum}"),
        subtitle: Text("customer's disposal: ${{
          "reshelf_as_spare": "Reshelf as Improved Packing",
          "abandon": "Abandon",
          "reshelf": "Reshelf",
          "other": "Other"
        }[element.disposal]}"),
        trailing: _tools(element),
      ));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    return widgets;
  }

  Widget _tools(ReturnedParcel rParcel) {
    List<ToolModel> toolOptions = [
      ToolModel("Reshelf", "reshelf"),
      ToolModel("Reshelf as Improved Packing", "reshelf_as_spare"),
      // ToolModel("As Problem Skus", "problem_sku"),
      ToolModel("Abandon", "abandon"),
      ToolModel("Other", "other"),
    ];
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return toolOptions.map<PopupMenuEntry<String>>((option) {
          return PopupMenuItem<String>(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
            ),
            value: option.value,
            child: Row(
              children: [
                const SizedBox(
                  width: 4,
                ),
                Text(
                  option.title,
                )
              ],
            ),
          );
        }).toList();
      },
      onSelected: (String select) {
        // print(value);
        // _alertDialog(value, "Warning");
        _confirm(select, rParcel);
      },
      icon: const Icon(
        Icons.more_horiz,
        color: primary,
      ),
    );
  }

  _alertDialog(String message, String title, ReturnedParcel rParcel,
      String select) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              MaterialButton(
                  onPressed: () {
                    Navigator.pop(context, "cancel");
                  },
                  child:
                      const Text("Cancel", style: TextStyle(color: primary))),
              MaterialButton(
                  onPressed: () {
                    _handle(select, rParcel);
                    Navigator.pop(context, "ok");
                  },
                  color: primary,
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          );
        });
  }

  void loadData({shpmtNumCont = ""}) async {
    try {
      String newShipmentNum = "";
      if (shpmtNumCont != null && shpmtNumCont != "") {
        newShipmentNum = matchShipmentNum(shpmtNumCont!);
      } else {
        newShipmentNum = shpmtNumCont;
      }
      var result = await ReturnedDao.get(
          shpmtNumCont: newShipmentNum, status: ["in_process"]);
      // print('loadData():$result');
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
        // print(result['reason']);
        showWarnToast(result['reason'].join(","));
        setState(() {
          _isLoading = false;
          parcelList.clear();
        });
      }
    } catch (e) {
      // print(e);
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

  void _confirm(String select, ReturnedParcel rParcel) {
    // 客户选择了其他处理方式时，仓库也只能选择其他。
    if ((select == "other" && rParcel.disposal != "other") ||
        (select != "other" && rParcel.disposal == "other")) {
      showWarnToast(
          "Customer's choice is ${rParcel.disposal}, you can not select $select");
      player.play('sounds/alert.mp3');
      return;
    }
    if (select != rParcel.disposal) {
      _alertDialog(
          "Your select($select) is not same as customer's choice(${rParcel.disposal}), Are You Sure?",
          "Warning",
          rParcel,
          select);
    } else {
      if (select == "other") {
        _alertDialog("${rParcel.disposalInfo}", "Handle Memo", rParcel, select);
      } else {
        // _alertDialog(
        //     "Your select is $select, Please Confirm!", "", rParcel, select);
        // 选择一致时，不跳Warning，直接处理
        _handle(select, rParcel);
      }
    }
  }

  void _handle(String select, ReturnedParcel rParcel) async {
    if (select == "reshelf" || select == "reshelf_as_spare") {
      rParcel.disposal = select;
      HiNavigator.getInstance().onJumpTo(RouteStatus.returnedNeedReshelf,
          args: {"needReshelParcel": rParcel});
    } else {
      setState(() {
        _isLoading = true;
      });
      try {
        var result = await ReturnedDao.finish(rParcel.id, select);
        // print(result);
        if (result['status'] == "succ") {
          showToast("Disposal Successful ");
          player.play('sounds/success01.mp3');
          setState(() {
            _isLoading = false;
            loadData(); // 重新加载数据
          });
        } else {
          showWarnToast(result['reason'].join(","));
          player.play('sounds/alert.mp3');
          setState(() {
            _isLoading = false;
            loadData(); // 重新加载数据
          });
        }
      } catch (e) {
        showWarnToast(e.toString());
        player.play('sounds/alert.mp3');
        setState(() {
          _isLoading = false;
          loadData(); // 重新加载数据
        });
      }
    }
  }
}

class ToolModel {
  String title;
  String value;

  ToolModel(this.title, this.value);
}
