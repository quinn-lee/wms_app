import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/check_dao.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/scan_input.dart';

class InventoryCheckScanPage extends StatefulWidget {
  const InventoryCheckScanPage({Key? key}) : super(key: key);

  @override
  State<InventoryCheckScanPage> createState() => _InventoryCheckScanPageState();
}

class _InventoryCheckScanPageState extends HiState<InventoryCheckScanPage> {
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? num;
  bool _isLoading = false;
  AudioCache player = AudioCache();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Inventory Check(Shelf Scan)", "", () {}),
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
      "Shelf",
      "Scan Shelf Num",
      focusNode,
      textEditingController,
      onChanged: (text) {
        num = text;
        // print("num: $num");
      },
      onSubmitted: (text) {
        _loadData();
      },
      // focusChanged: (bool hasFocus) {
      //   if (!hasFocus) {}
      // },
    ));
    return widgets;
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (num != null && num != "") {
        var result = await CheckDao.addShelfNum(num!);
        // print('loadData():$result');
        if (result['status'] == "succ") {
          setState(() {
            _isLoading = false;
            print(result['data']);
          });
          player.play('sounds/success01.mp3');
          HiNavigator.getInstance().onJumpTo(RouteStatus.inventoryCheckOperate,
              args: {
                "checkShelfNum": num,
                "checkSkus": result['data']['skus']
              });
        } else {
          // print(result['reason']);
          showWarnToast(result['reason'].join(","));
          setState(() {});
          player.play('sounds/alert.mp3');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
      });
      player.play('sounds/alert.mp3');
    }
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }
}
