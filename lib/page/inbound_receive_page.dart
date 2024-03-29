import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/inbound_dao.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/scan_input.dart';

class InboundReceivePage extends StatefulWidget {
  const InboundReceivePage({Key? key}) : super(key: key);

  @override
  State<InboundReceivePage> createState() => _InboundReceivePageState();
}

class _InboundReceivePageState extends HiState<InboundReceivePage> {
  AudioCache player = AudioCache();
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? num;
  List<Map> resultShow = [];
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
        appBar: appBar("Receive Parcels", "", () {}),
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
      "Scan parcel's shipment no",
      focusNode,
      textEditingController,
      onChanged: (text) {
        num = text;
        // print("num: $num");
      },
      onSubmitted: (text) {
        _send();
      },
    ));

    for (var element in resultShow.reversed) {
      widgets.add(InkWell(
          onTap: () {
            if (element['category'] == "return") {
              HiNavigator.getInstance().onJumpTo(RouteStatus.returnedNewScan,
                  args: {"newReturnPageFrom": "receive"});
            } else if (element['category'] == "unknown") {
              HiNavigator.getInstance().onJumpTo(RouteStatus.unknownPacks,
                  args: {"unknownPageFrom": "receive"});
            }
          },
          child: ListTile(
            title: Text(
              element['show'],
              style: const TextStyle(color: Colors.white),
            ),
            tileColor: {
              "inbound": const Color(0xFF4e72b8),
              "return": const Color(0xFF6a6da9),
              "unknown": const Color(0xFFafb4db),
              "error": const Color(0xFFf15b6c)
            }[element['category']],
          )));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    return widgets;
  }

  void _send() async {
    setState(() {
      _isLoading = true;
    });
    dynamic result;
    try {
      if (num != null && num != "") {
        String newShipmentNum = matchShipmentNum(num!);
        result = await InboundDao.receive(newShipmentNum);
        if (result["status"] == "succ") {
          setState(() {
            _isLoading = false;
            var now = DateTime.now();
            String show = "";
            if (result["category"] == "inbound") {
              show =
                  "${now.hour}:${now.minute}:${now.second}-${result['category']} parcel! Num:$newShipmentNum, inbound_num:${result['inbound_num']}, customer:${result['abbr_code']}";
            } else if (result["category"] == "return") {
              show =
                  "${now.hour}:${now.minute}:${now.second}-${result['category']} parcel! Num:$newShipmentNum, Click to Register Return Parcel";
            } else if (result["category"] == "unknown") {
              show =
                  "${now.hour}:${now.minute}:${now.second}-${result['category']} parcel! Num:$newShipmentNum, Click to Register Unknown Parcel";
            } else {
              show =
                  "${now.hour}:${now.minute}:${now.second}-${result['category']} parcel! Num:$newShipmentNum";
            }
            resultShow.add({"category": result["category"], "show": show});

            if (result["category"] == "inbound") {
              player.play('sounds/inbound.mp3');
            } else if (result["category"] == "return") {
              player.play('sounds/return.mp3');
            } else {
              player.play('sounds/unknown.mp3');
            }
          });
        } else {
          setState(() {
            _isLoading = false;
            resultShow
                .add({"category": "error", "show": result['reason'].join(",")});
          });
          player.play('sounds/alert.mp3');
          showWarnToast(result['reason'].join(","));
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        resultShow.add({"category": "error", "show": e.toString()});
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
