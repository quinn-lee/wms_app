import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/depot_dao.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/model/returned_sku.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/cancel_button.dart';
import 'package:wms_app/widget/loading_container.dart';
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
  List<DropdownMenuItem<String>> depots = [];
  FocusNode focusNode = FocusNode();
  String? num;
  List<Map> resultShow = [];
  List<ReturnedSku> skuList = [];
  bool canSubmit = false;
  AudioCache player = AudioCache();
  String batchNum = "";
  String description = "";
  String returnSt = "";
  String? depotCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadDepotData();
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

  void loadDepotData() async {
    try {
      var result = await DepotDao.getDepotList();
      if (result['status'] == "succ") {
        if (result['data'].length > 0) {
          for (var depot in result['data']) {
            setState(() {
              depots.add(DropdownMenuItem(value: depot, child: Text(depot)));
            });
          }
          // setState(() {
          //   depotCode = result['data'][0];
          // });
        } else {
          showWarnToast("No Depots Found");
          HiNavigator.getInstance().onJumpTo(RouteStatus.inboundPage);
        }
      } else {
        showWarnToast(result['reason'].join(","));
        HiNavigator.getInstance().onJumpTo(RouteStatus.inboundPage);
      }
    } catch (e) {
      showWarnToast(e.toString());
      HiNavigator.getInstance().onJumpTo(RouteStatus.inboundPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Returned Scan", "", () {}),
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
    widgets.add(_selectDepot());
    widgets.add(const Divider(
      height: 1,
      color: Colors.white,
    ));
    if (batchNum != "") {
      if (description != "") {
        widgets.add(ListTile(
          title: Text("$num, $batchNum"),
          subtitle: Text(description),
        ));
      } else {
        widgets.add(ListTile(title: Text("$num, $batchNum")));
      }
    }
    if (returnSt != "") {
      widgets.add(ListTile(
          title: Text(
        "WARNING INFO: $returnSt",
        style: const TextStyle(fontSize: 20, color: Color(0xffDC143C)),
      )));
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

  // 类别选项
  Widget _selectDepot() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15),
              width: 120,
              child: const Text(
                "Depot",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        value: depotCode,
                        elevation: 12,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.black),
                        iconEnabledColor: Colors.green,
                        onChanged: (newValue) {
                          setState(() {
                            depotCode = newValue!;
                            if (batchNum != "") canSubmit = true;
                          });
                        },
                        items: depots)))
          ],
        ),
        const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Divider(
              height: 1,
              thickness: 0.5,
            ))
      ],
    );
  }

  void _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (num != null && num != "") {
        String newShipmentNum = matchShipmentNum(num!);
        var result = await ReturnedDao.getReturnedSkus(newShipmentNum);
        // print('loadData():$result');
        if (result['status'] == "succ") {
          setState(() {
            skuList.clear();
            _isLoading = false;
            batchNum = result['data']['batch_num'];
            description = result['data']['description'] ?? '';
            returnSt = result['data']['return_st'] ?? '';

            for (var item in result['data']['skus']) {
              skuList.add(ReturnedSku.fromJson(item));
            }
            if (depotCode != null) canSubmit = true;
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
          // print(result['reason']);
          showWarnToast(result['reason'].join(","));
          setState(() {
            _isLoading = false;
            resultShow
                .add({"status": false, "show": result['reason'].join(",")});
            skuList.clear();
            batchNum = "";
            description = "";
            returnSt = "";
            canSubmit = false;
          });
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
        resultShow.add({"status": false, "show": e.toString()});
        canSubmit = false;
        batchNum = "";
        description = "";
        returnSt = "";
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
      returnSt = "";
      depotCode = null;
      skuList.clear();
    });
  }

  void _send() async {
    dynamic result;
    setState(() {
      canSubmit = false; // 防止重复提交
      _isLoading = true;
    });
    try {
      if (num != null && num != "") {
        String newShipmentNum = matchShipmentNum(num!);
        result = await ReturnedDao.scan(newShipmentNum, depotCode!,
            skipDispose: true);
        if (result["status"] == "succ") {
          setState(() {
            _isLoading = false;
            var now = DateTime.now();
            resultShow.add({
              "status": true,
              "show":
                  "${now.hour}:${now.minute}:${now.second}-Succeeded! Num:$newShipmentNum"
            });
            skuList.clear();
            batchNum = "";
            description = "";
            returnSt = "";
            canSubmit = false;
          });
          player.play('sounds/success01.mp3');
          showToast("Submit Successful");
        } else {
          setState(() {
            _isLoading = false;
            resultShow
                .add({"status": false, "show": result['reason'].join(",")});
            skuList.clear();
            batchNum = "";
            description = "";
            returnSt = "";
            canSubmit = false;
          });
          player.play('sounds/alert.mp3');
          showWarnToast(result['reason'].join(","));
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        resultShow.add({"status": false, "show": e.toString()});
        skuList.clear();
        batchNum = "";
        description = "";
        returnSt = "";
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
      _isLoading = true;
    });
    try {
      if (num != null && num != "") {
        String newShipmentNum = matchShipmentNum(num!);
        result = await ReturnedDao.scan(newShipmentNum, depotCode!);
        if (result["status"] == "succ") {
          setState(() {
            _isLoading = false;
            var now = DateTime.now();
            resultShow.add({
              "status": true,
              "show":
                  "${now.hour}:${now.minute}:${now.second}-Succeeded! Num:$newShipmentNum"
            });
            skuList.clear();
            batchNum = "";
            description = "";
            returnSt = "";
            canSubmit = false;
          });
          player.play('sounds/success01.mp3');
          showToast("Submit Successful");
          // print(result["data"]);
          ReturnedParcel rp = ReturnedParcel.fromJson(result["data"]);
          String photoFrom =
              (widget.pageFrom == "receive" ? widget.pageFrom : "scan");
          HiNavigator.getInstance().onJumpTo(RouteStatus.returnedPhoto,
              args: {"needPhotoParce": rp, "photoFrom": photoFrom});
        } else {
          setState(() {
            _isLoading = false;
            resultShow
                .add({"status": false, "show": result['reason'].join(",")});
            skuList.clear();
            batchNum = "";
            description = "";
            returnSt = "";
            canSubmit = false;
          });
          player.play('sounds/alert.mp3');
          showWarnToast(result['reason'].join(","));
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        resultShow.add({"status": false, "show": e.toString()});
        skuList.clear();
        batchNum = "";
        description = "";
        returnSt = "";
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
