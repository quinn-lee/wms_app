import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/outbound_dao.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/cancel_button.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/scan_input.dart';

class OutboundOosRegistrationPage extends StatefulWidget {
  const OutboundOosRegistrationPage({Key? key}) : super(key: key);

  @override
  State<OutboundOosRegistrationPage> createState() =>
      _OutboundOosRegistrationPageState();
}

class _OutboundOosRegistrationPageState
    extends HiState<OutboundOosRegistrationPage> {
  String shipmentNum = "";
  String? num;
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool _isLoading = false;
  List<Map> resultShow = [];
  AudioCache player = AudioCache();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('OOS Registration'),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
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
      "Scan No",
      "Scan Number",
      focusNode,
      textEditingController,
      onChanged: (text) {
        num = text;
      },
      onSubmitted: (text) {
        _assignData();
      },
    ));
    if (shipmentNum.isNotEmpty) {
      widgets.add(ListTile(
          title: Text(
            shipmentNum,
            style: const TextStyle(color: Colors.white),
          ),
          tileColor: const Color(0xFFDCDCDC)));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
      widgets.add(Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              LoginButton(
                'Submit',
                1,
                enable: true,
                onPressed: upload,
              ),
            ],
          )));
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

  void _assignData() {
    if (num == null || num == "") {
      showWarnToast("Please Scan Number");
    } else {
      if (num!.length == 28 && num!.substring(0, 1) == '%') {
        setState(() {
          shipmentNum = num!.substring(8, 22);
        });
      } else if (num!.startsWith("0145") ||
          num!.startsWith("0150") ||
          num!.startsWith("094")) {
        setState(() {
          shipmentNum = num!;
        });
      } else {
        showWarnToast("$num Is Not A Waybill Number");
        setState(() {
          resultShow
              .add({"status": false, "show": "$num Is Not A Waybill Number"});
        });
      }
    }
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  void upload() async {
    setState(() {
      _isLoading = true;
    });
    dynamic result;
    try {
      result = await OutboundDao.scanLog([shipmentNum]);
      if (result['status'] == "succ") {
        showToast("Oos Registration Successful");
        var now = DateTime.now();
        setState(() {
          _isLoading = false;
          resultShow.add({
            "status": true,
            "show":
                "${now.hour}:${now.minute}:${now.second} - Succeeded! $shipmentNum"
          });
        });
        player.play('sounds/success01.mp3');
      } else {
        showWarnToast(result['reason'].join(","));
        setState(() {
          _isLoading = false;
          resultShow.add({"status": false, "show": result['reason'].join(",")});
        });
        player.play('sounds/alert.mp3');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        resultShow.add({"status": false, "show": e.toString()});
      });
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    setState(() {
      num = null;
      shipmentNum = "";
      _isLoading = false;
      textEditingController.clear();
    });
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }
}
