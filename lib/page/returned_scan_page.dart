import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/model/returned_sku.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/cancel_button.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/scan_input.dart';

class ReturnedScanPage extends StatefulWidget {
  final String pageFrom;
  const ReturnedScanPage(this.pageFrom, {Key? key}) : super(key: key);

  @override
  State<ReturnedScanPage> createState() => _ReturnedScanPageState();
}

class _ReturnedScanPageState extends HiState<ReturnedScanPage> {
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? num;
  List<Map> resultShow = [];
  List<ReturnedSku> skuList = [];
  bool canSubmit = false;
  AudioCache player = AudioCache();
  String batchNum = "";
  String description = "";

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() {
      // print("controller: ${textEditingController.text}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Returned Scan", "", () {}),
      body: ListView(
        children: _buildWidget(),
      ),
    );
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
        // _send();
        _loadData();
      },
      // focusChanged: (bool hasFocus) {
      //   if (!hasFocus) {}
      // },
    ));
    widgets.add(const Divider(
      height: 1,
      color: Colors.white,
    ));
    if (batchNum != "") {
      widgets.add(ListTile(
        title: Text("$num, $batchNum"),
        subtitle: Text(description),
      ));
    }
    for (var element in skuList) {
      widgets.add(Card(
        child: Column(
          children: [
            ListTile(
              title: Text("${element.skuCode}, ${element.barcode}"),
              subtitle: Text(
                  "name: ${element.foreignName}, quantity: ${element.quantity}"),
            )
          ],
        ),
      ));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    if (batchNum != "") {
      widgets.add(Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              LoginButton(
                'Submit',
                0.45,
                enable: canSubmit,
                onPressed: _send,
              ),
              CancelButton(
                'Cancel',
                0.45,
                enable: canSubmit,
                onPressed: _cancel,
              ),
            ],
          )));
      widgets.add(Padding(
        padding: const EdgeInsets.all(10),
        child: LoginButton(
          'Submit With Photos',
          1,
          enable: canSubmit,
          onPressed: _sendAndPhoto,
        ),
      ));
    }
    for (var element in resultShow.reversed) {
      widgets.add(ListTile(
        title: Text(
          element['show'],
          style: const TextStyle(color: Colors.white),
        ),
        tileColor: element['status']
            ? const Color(0xFF4e72b8)
            : const Color(0xFFf15b6c),
      ));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    return widgets;
  }

  void _loadData() async {
    try {
      if (num != null && num != "") {
        var result = await ReturnedDao.getReturnedSkus(num!);
        print('loadData():$result');
        if (result['status'] == "succ") {
          setState(() {
            skuList.clear();
            batchNum = result['data']['batch_num'];
            description = result['data']['description'];
            for (var item in result['data']['skus']) {
              skuList.add(ReturnedSku.fromJson(item));
            }
            canSubmit = true;
          });
          // if (result['data']['skus'].length == 0) {
          //   setState(() {
          //     skuList.clear();
          //     batchNum = "";
          //     description = "";
          //     canSubmit = false;
          //     resultShow
          //         .add({"status": false, "show": "$num, No Sku Info Found"});
          //   });
          //   showWarnToast("No Sku Info Found");
          // }
        } else {
          print(result['reason']);
          showWarnToast(result['reason'].join(","));
          setState(() {
            resultShow
                .add({"status": false, "show": result['reason'].join(",")});
            skuList.clear();
            batchNum = "";
            description = "";
            canSubmit = false;
          });
          player.play('sounds/alert.mp3');
        }
      }
    } catch (e) {
      print(e);
      showWarnToast(e.toString());
      setState(() {
        resultShow.add({"status": false, "show": e.toString()});
        canSubmit = false;
        batchNum = "";
        description = "";
        skuList.clear();
      });
      player.play('sounds/alert.mp3');
    }
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  void _cancel() {
    setState(() {
      canSubmit = false;
      batchNum = "";
      description = "";
      skuList.clear();
    });
  }

  void _send() async {
    dynamic result;
    setState(() {
      canSubmit = false; // 防止重复提交
    });
    try {
      if (num != null && num != "") {
        result = await ReturnedDao.scan(num!);
        if (result["status"] == "succ") {
          setState(() {
            var now = DateTime.now();
            resultShow.add({
              "status": true,
              "show":
                  "${now.hour}:${now.minute}:${now.second}-Succeeded! Num:$num"
            });
            skuList.clear();
            batchNum = "";
            description = "";
            canSubmit = false;
          });
          player.play('sounds/success01.mp3');
          showToast("Submit Successful");
        } else {
          setState(() {
            resultShow
                .add({"status": false, "show": result['reason'].join(",")});
            skuList.clear();
            batchNum = "";
            description = "";
            canSubmit = false;
          });
          player.play('sounds/alert.mp3');
          showWarnToast(result['reason'].join(","));
        }
      }
    } catch (e) {
      setState(() {
        resultShow.add({"status": false, "show": e.toString()});
        skuList.clear();
        batchNum = "";
        description = "";
        canSubmit = false;
      });
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
    if (widget.pageFrom == "receive") {
      HiNavigator.getInstance().onJumpTo(RouteStatus.inboundReceive);
    }
  }

  void _sendAndPhoto() async {
    dynamic result;
    setState(() {
      canSubmit = false; // 防止重复提交
    });
    try {
      if (num != null && num != "") {
        result = await ReturnedDao.scan(num!);
        if (result["status"] == "succ") {
          setState(() {
            var now = DateTime.now();
            resultShow.add({
              "status": true,
              "show":
                  "${now.hour}:${now.minute}:${now.second}-Succeeded! Num:$num"
            });
            skuList.clear();
            batchNum = "";
            description = "";
            canSubmit = false;
          });
          player.play('sounds/success01.mp3');
          showToast("Submit Successful");
          print(result["data"]);
          ReturnedParcel rp = ReturnedParcel.fromJson(result["data"]);
          String photoFrom =
              (widget.pageFrom == "receive" ? widget.pageFrom : "scan");
          HiNavigator.getInstance().onJumpTo(RouteStatus.returnedPhoto,
              args: {"needPhotoParce": rp, "photoFrom": photoFrom});
        } else {
          setState(() {
            resultShow
                .add({"status": false, "show": result['reason'].join(",")});
            skuList.clear();
            batchNum = "";
            description = "";
            canSubmit = false;
          });
          player.play('sounds/alert.mp3');
          showWarnToast(result['reason'].join(","));
        }
      }
    } catch (e) {
      setState(() {
        resultShow.add({"status": false, "show": e.toString()});
        skuList.clear();
        batchNum = "";
        description = "";
        canSubmit = false;
      });
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }
}
