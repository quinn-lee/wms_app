import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/outbound_dao.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/cancel_button.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/scan_input.dart';

class OutboundCheckPage extends StatefulWidget {
  const OutboundCheckPage({Key? key}) : super(key: key);

  @override
  State<OutboundCheckPage> createState() => _OutboundCheckPageState();
}

class _OutboundCheckPageState extends HiState<OutboundCheckPage> {
  String? num;
  String? shipmentNum;
  String? barcode;
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController1 = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  final TextEditingController textEditingController2 = TextEditingController();
  FocusNode focusNode2 = FocusNode();
  bool submitEnable = false;
  List<Map> resultShow = [];
  AudioCache player = AudioCache();
  bool _isLoading = false;

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
    focusNode1.dispose();
    textEditingController1.dispose();
    focusNode2.dispose();
    textEditingController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Single Item Check(Drop Shipping)'),
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

  // 组装页面
  List<Widget> _buildWidget() {
    List<Widget> widgets = [];
    widgets.add(ScanInput(
      "Single Item\nScan No",
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
    widgets.add(const Divider(
      thickness: 32,
      color: Color(0XFFEEEEEE),
      height: 30,
    ));
    widgets.add(ScanInput(
      "SKU Code/Barcode",
      "SKU Code/Barcode",
      focusNode2,
      textEditingController2,
      enabled: false,
    ));
    widgets.add(ScanInput(
      "Shipment Num",
      "Shipment Number",
      focusNode1,
      textEditingController1,
      enabled: false,
    ));
    widgets.add(Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            LoginButton(
              'Multiple Item?\nClick Here',
              0.45,
              enable: true,
              onPressed: () {
                HiNavigator.getInstance()
                    .onJumpTo(RouteStatus.outboundCheckMultiple);
              },
            ),
            LoginButton(
              'No Stock?\nClick Here',
              0.45,
              enable: true,
              onPressed: () {
                HiNavigator.getInstance()
                    .onJumpTo(RouteStatus.outboundOosRegistration);
              },
            ),
          ],
        )));
    widgets.add(Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            CancelButton(
              'Clear',
              1,
              enable: true,
              onPressed: clear,
            ),
          ],
        )));

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

  void clear() {
    setState(() {
      shipmentNum = null;
      barcode = null;
    });
    if (mounted) {
      textEditingController.clear();
      textEditingController1.clear();
      textEditingController2.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  void _assignData() {
    if (num == null || num == "") {
      showWarnToast("Please Scan Number");
    } else {
      if (num!.length == 28 && num!.substring(0, 1) == '%') {
        shipmentNum = num!.substring(8, 22);
        textEditingController1.text = num!.substring(8, 22);
      } else if (num!.startsWith("0145") ||
          num!.startsWith("0150") ||
          num!.startsWith("094")) {
        shipmentNum = num!;
        textEditingController1.text = num!;
      } else {
        barcode = num!;
        textEditingController2.text = num!;
      }
    }
    if (isNotEmpty(shipmentNum) && isNotEmpty(barcode)) {
      upload();
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
      result = await OutboundDao.check(shipmentNum!, barcode!);
      if (result['status'] == "succ") {
        showToast("Check Outbound Order Successful");
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
      _isLoading = false;
      shipmentNum = null;
      barcode = null;
      textEditingController.clear();
      textEditingController1.clear();
      textEditingController2.clear();
    });
  }
}
