import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/login_button.dart';
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
  bool canSubmit = false;
  AudioCache player = AudioCache();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() {
      // print("controller: ${textEditingController.text}");
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar("Returned Reshelf", "", () {}),
      body: LoadingContainer(
        cover: true,
        isLoading: _isLoading,
        child: ListView(
          children: _buildWidget(),
        ),
      ),
    );
  }

  List<Widget> _buildWidget() {
    List<Widget> widgets = [];
    widgets.add(ListTile(
      title: const Text("Shipment Num: "),
      subtitle: Text("${widget.returnedParcel.shpmtNum}"),
    ));
    widgets.add(ListTile(
      title: const Text("Return Num: "),
      subtitle: Text("${widget.returnedParcel.roNum}"),
    ));
    widgets.add(ListTile(
      title: const Text("Disposal: "),
      subtitle: Text("${widget.returnedParcel.disposal}"),
    ));
    if (widget.returnedParcel.disposal == "reshelf") {
      widgets.add(ListTile(
        title: const Text("Repacking?"),
        subtitle: widget.returnedParcel.disposalVas!['new_carton'] == true
            ? const Text("YES.",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18))
            : const Text("No."),
      ));
      widgets.add(ListTile(
        title: const Text("Reinforced wrapping?"),
        subtitle:
            widget.returnedParcel.disposalVas!['tape_reinforcement'] == true
                ? const Text("YES.",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18))
                : const Text("No."),
      ));
    }
    widgets.add(ScanInput(
      "Shelf",
      "Scan Shelf's Barcode",
      focusNode,
      textEditingController,
      onChanged: (text) {
        shelfNum = text;
        checkInput();
      },
    ));
    widgets.add(Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: LoginButton(
        'Submit',
        1,
        enable: canSubmit,
        onPressed: _send,
      ),
    ));
    return widgets;
  }

  void checkInput() {
    bool enable;
    if (isNotEmpty(shelfNum)) {
      enable = true;
    } else {
      enable = false;
    }
    setState(() {
      canSubmit = enable;
    });
  }

  _send() async {
    setState(() {
      canSubmit = false;
      _isLoading = true;
    });
    dynamic result;
    try {
      if (shelfNum != null && shelfNum != "") {
        result = await ReturnedDao.finish(
            widget.returnedParcel.id, widget.returnedParcel.disposal!,
            shelfNum: shelfNum);
        setState(() {
          _isLoading = false;
        });
        if (result["status"] == "succ") {
          player.play('sounds/success01.mp3');
          showToast("Reshelf Successful");
        } else {
          player.play('sounds/alert.mp3');
          showWarnToast(result['reason'].join(","));
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    HiNavigator.getInstance().onJumpTo(RouteStatus.returnedNeedProcess);
  }
}
