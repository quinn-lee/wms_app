import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/http/dao/outbound_dao.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/cancel_button.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/scan_input.dart';
import 'package:wms_app/widget/show_input.dart';

class OutboundCheckMultiplePage extends StatefulWidget {
  const OutboundCheckMultiplePage({Key? key}) : super(key: key);

  @override
  State<OutboundCheckMultiplePage> createState() =>
      _OutboundCheckMultiplePageState();
}

class _OutboundCheckMultiplePageState extends State<OutboundCheckMultiplePage> {
  String? num;
  String? shipmentNum;
  Map skuInfo = {};
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController1 = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  bool submitEnable = false;
  List<Map> resultShow = [];
  AudioCache player = AudioCache();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Orders Multiple(Drop Shipping)'),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        children: _buildWidget(),
      ),
    );
  }

  // 组装页面
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
        checkInput();
      },
    ));
    widgets.add(Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: LoginButton(
        'Finish Scan',
        1,
        enable: submitEnable,
        onPressed: upload,
      ),
    ));

    widgets.add(ScanInput(
      "Shpmt Num",
      "Shpmt Num",
      focusNode1,
      textEditingController1,
      enabled: false,
    ));
    skuInfo.forEach((key, value) {
      TextEditingController tec = TextEditingController();
      tec.text = value.toString();
      widgets.add(ShowInput(
        "SKU Code/Barcode($key)",
        "",
        FocusNode(),
        tec,
        enabled: false,
      ));
    });
    widgets.add(Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            LoginButton(
              'To Check Orders Page',
              0.45,
              enable: true,
              onPressed: () {
                HiNavigator.getInstance().onJumpTo(RouteStatus.outboundCheck);
              },
            ),
            CancelButton(
              'Clear',
              0.45,
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

  void _assignData() {
    if (num == null || num == "") {
      showWarnToast("Please Scan Number");
    } else {
      // if (shipmentNum == null) {
      //   String newShipmentNum = matchShipmentNum(num!);
      //   shipmentNum = newShipmentNum;
      //   textEditingController1.text = newShipmentNum;
      // } else {
      //   if (skuInfo.containsKey(num!)) {
      //     setState(() {
      //       skuInfo[num!] = skuInfo[num!] + 1;
      //     });
      //   } else {
      //     setState(() {
      //       skuInfo[num!] = 1;
      //     });
      //   }
      // }
      if (num!.length == 28 && num!.substring(0, 1) == '%') {
        shipmentNum = num!.substring(8, 22);
        textEditingController1.text = num!.substring(8, 22);
      } else if (num!.startsWith("0145") ||
          num!.startsWith("0150") ||
          num!.startsWith("094")) {
        shipmentNum = num!;
        textEditingController1.text = num!;
      } else {
        if (skuInfo.containsKey(num!)) {
          setState(() {
            skuInfo[num!] = skuInfo[num!] + 1;
          });
        } else {
          setState(() {
            skuInfo[num!] = 1;
          });
        }
      }
    }
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  void checkInput() {
    if (skuInfo.isNotEmpty && isNotEmpty(shipmentNum)) {
      setState(() {
        submitEnable = true;
      });
    } else {
      setState(() {
        submitEnable = false;
      });
    }
  }

  void clear() {
    setState(() {
      submitEnable = false;
      shipmentNum = null;
      skuInfo = {};
      textEditingController.clear();
      textEditingController1.clear();
    });
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  void upload() async {
    setState(() {
      submitEnable = false;
    });
    dynamic result;
    try {
      List newSkuInfo = [];
      skuInfo.forEach((key, value) {
        newSkuInfo.add({"barcode": key, "quantity": value});
      });
      String newShipmentNum = matchShipmentNum(shipmentNum!);
      result = await OutboundDao.checkMultiple(newShipmentNum, newSkuInfo);
      if (result['status'] == "succ") {
        showToast("Check Outbound Order Successful");
        var now = DateTime.now();
        setState(() {
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
          resultShow.add({"status": false, "show": result['reason'].join(",")});
        });
        player.play('sounds/alert.mp3');
      }
    } catch (e) {
      setState(() {
        resultShow.add({"status": false, "show": e.toString()});
      });
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    setState(() {
      shipmentNum = null;
      skuInfo = {};
      textEditingController.clear();
      textEditingController1.clear();
    });
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }
}
