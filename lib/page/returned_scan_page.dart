import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/scan_input.dart';

class ReturnedScanPage extends StatefulWidget {
  const ReturnedScanPage({Key? key}) : super(key: key);

  @override
  State<ReturnedScanPage> createState() => _ReturnedScanPageState();
}

class _ReturnedScanPageState extends HiState<ReturnedScanPage> {
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? num;
  List<Map> resultShow = [];
  AudioCache player = AudioCache();

  @override
  void initState() {
    textEditingController.addListener(() {
      print("controller: ${textEditingController.text}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Returned Scan", "", () {}),
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
        _send();
      },
      focusChanged: (bool hasFocus) {
        if (!hasFocus) {}
      },
    ));
    widgets.add(const Divider(
      height: 1,
      color: Colors.white,
    ));
    for (var element in resultShow.reversed) {
      widgets.add(ListTile(
        title: Text(element['show']),
        tileColor: element['status']
            ? const Color(0xFFdff0f8)
            : const Color(0xFFf2dede),
      ));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    return widgets;
  }

  void _send() async {
    dynamic result;
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
          });
          player.play('sounds/success01.mp3');
          showToast("Scan Successful");
        } else {
          setState(() {
            resultShow
                .add({"status": false, "show": result['reason'].join(",")});
          });
          player.play('sounds/alert.mp3');
          showWarnToast(result['reason'].join(","));
        }
      }
    } catch (e) {
      setState(() {
        resultShow.add({"status": false, "show": e.toString()});
      });
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    textEditingController.clear();
    FocusScope.of(context).requestFocus(focusNode);
  }
}
