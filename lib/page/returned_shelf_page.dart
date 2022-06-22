import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/scan_input.dart';

class ReturnedShelfPage extends StatefulWidget {
  final ReturnedParcel returnedParcel;
  const ReturnedShelfPage(this.returnedParcel, {Key? key}) : super(key: key);

  @override
  State<ReturnedShelfPage> createState() => _ReturnedShelfPageState();
}

class _ReturnedShelfPageState extends HiState<ReturnedShelfPage> {
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? shelfNum;
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
      appBar: appBar("Returned Reshelf", "", () {}),
      body: Container(
        child: ListView(
          children: [
            ListTile(
              title: const Text("Shipment Num: "),
              subtitle: Text("${widget.returnedParcel.shpmtNum}"),
            ),
            ListTile(
              title: const Text("Disposal: "),
              subtitle: Text("${widget.returnedParcel.disposal}"),
            ),
            ScanInput(
              "Shelf",
              "Scan Shelf's Barcode",
              focusNode,
              textEditingController,
              onChanged: (text) {
                shelfNum = text;
                print("shelfNum: $shelfNum");
              },
              onSubmitted: (text) {
                _send();
              },
              focusChanged: (bool hasFocus) {
                if (!hasFocus) {}
              },
            )
          ],
        ),
      ),
    );
  }

  _send() async {
    dynamic result;
    try {
      if (shelfNum != null && shelfNum != "") {
        result = await ReturnedDao.finish(
            widget.returnedParcel.id, widget.returnedParcel.disposal!,
            shelfNum: shelfNum);
        if (result["status"] == "succ") {
          player.play('sounds/success01.mp3');
          showToast("Reshelf Successful");
        } else {
          player.play('sounds/alert.mp3');
          showWarnToast(result['reason'].join(","));
        }
      }
    } catch (e) {
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    HiNavigator.getInstance().onJumpTo(RouteStatus.returnedNeedProcess);
  }
}
