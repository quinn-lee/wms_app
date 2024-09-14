import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/depot_dao.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/model/returned_sku.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/color.dart';
import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/cancel_button.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/scan_input.dart';

class ReturnedNewScanPage extends StatefulWidget {
  final String pageFrom;
  const ReturnedNewScanPage(this.pageFrom, {Key? key}) : super(key: key);

  @override
  State<ReturnedNewScanPage> createState() => _ReturnedNewScanPageState();
}

class _ReturnedNewScanPageState extends HiState<ReturnedNewScanPage> {
  final TextEditingController textEditingController = TextEditingController();
  List<DropdownMenuItem<String>> depots = [];
  FocusNode focusNode = FocusNode();
  String? num;
  List<Map> resultShow = [];
  List<ReturnedSku> skuList = [];
  List<ReturnedSku> skuList1 = [];
  bool canSubmit = false;
  AudioCache player = AudioCache();
  String batchNum = "";
  String batchNum1 = "";
  String description = "";
  String returnSt = "";
  String defaultDisposal = "";
  String depotCode = "DUI-E9"; // 默认E9仓库
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print("from: ${widget.pageFrom}");
    loadDepotData();
    setState(() {
      clear();
    });

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
          HiNavigator.getInstance().onJumpTo(RouteStatus.returnedPage);
        }
      } else {
        showWarnToast(result['reason'].join(","));
        HiNavigator.getInstance().onJumpTo(RouteStatus.returnedPage);
      }
    } catch (e) {
      showWarnToast(e.toString());
      HiNavigator.getInstance().onJumpTo(RouteStatus.returnedPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Returned Scan(NEW!)", "", () {}),
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
        _loadData();
      },
      // focusChanged: (bool hasFocus) {
      //   if (!hasFocus) {}
      // },
    ));
    if (batchNum != "") {
      String newNum = matchShipmentNum(num!);
      if (description != "") {
        widgets.add(ListTile(
          title: Text("$newNum, $batchNum"),
          subtitle: Text(description),
        ));
      } else {
        widgets.add(ListTile(title: Text("$newNum, $batchNum")));
      }
    }
    if (returnSt != "") {
      widgets.add(ListTile(
          title: Text(
        "WARNING INFO: $returnSt",
        style: const TextStyle(fontSize: 20, color: Color(0xffDC143C)),
      )));
      if (returnSt == "wrong_shipment") {
        widgets.add(const ListTile(
            title: Text(
          "Wrong shipment returned, please DO NOT Abandon. DO NOT Abandon",
          style: TextStyle(fontSize: 20, color: Color(0xffDC143C)),
        )));
      }
    }
    for (var element in skuList) {
      widgets.add(Card(
        child: Column(
          children: [
            ListTile(
              title: Text("${element.skuCode}, ${element.shortCode}"),
              subtitle: Text(
                  "Stock: ${element.inventoryQuantity}, Shelf: ${element.currentShelf}"),
            )
          ],
        ),
      ));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    widgets.add(_selectDepot());
    widgets.add(const Divider(
      height: 1,
      color: Colors.white,
    ));
    if (batchNum != "") {
      widgets.add(const ListTile(
          title: Text(
        "If the package is undamaged, \nselect <Reshelf>",
        style:
            TextStyle(fontSize: 20, color: Color.fromARGB(255, 20, 113, 220)),
      )));
      widgets.add(Padding(
          padding: const EdgeInsets.all(10),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              LoginButton(
                'Reshelf',
                0.45,
                enable: canSubmit,
                onPressed: _reshelf,
              ),
              CancelButton(
                'Cancel',
                0.45,
                enable: canSubmit,
                onPressed: _cancel,
              ),
            ],
          )));
      if (defaultDisposal == "reshelf_as_spare" ||
          defaultDisposal == "abandon") {
        String? choice = {
          "reshelf_as_spare": "New Packing",
          "abandon": "Abandon"
        }[defaultDisposal];
        widgets.add(ListTile(
            title: RichText(
          text: TextSpan(
              text:
                  "If the package is broken, please select <New Packing> or <Abandon>. Customer's default choice is ",
              style: const TextStyle(
                  fontSize: 20, color: Color.fromARGB(255, 20, 113, 220)),
              children: <TextSpan>[
                TextSpan(
                    text: choice!,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold))
              ]),
        )));
        widgets.add(Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                LoginButton(
                  'New Packing',
                  0.45,
                  enable: canSubmit,
                  onPressed: _changePacking,
                ),
                LoginButton(
                  'Abandon',
                  0.45,
                  enable: canSubmit,
                  onPressed: _abandon,
                ),
              ],
            )));
      } else {
        widgets.add(const ListTile(
            title: Text(
          "If the package is broken(customer's default choice is blank), please select <Submit With Photos>",
          style:
              TextStyle(fontSize: 20, color: Color.fromARGB(255, 20, 113, 220)),
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
    }
    for (var element in resultShow.reversed) {
      if (element['status']) {
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
      } else {
        if (element['num'] != null && element['show'].contains('not found')) {
          widgets.add(ListTile(
            title: Text(
              "${element['show']}, create a new return parcel manually?",
              style: const TextStyle(color: Colors.white),
            ),
            tileColor: element['status']
                ? const Color(0xFF4e72b8)
                : const Color(0xFFf15b6c),
            trailing: const Icon(Icons.navigate_next),
            onTap: () {
              HiNavigator.getInstance().onJumpTo(
                  RouteStatus.returnedUnknownHandle,
                  args: {"returnedShpmtNum": element['num']});
            },
          ));
          widgets.add(const Divider(
            height: 1,
            color: Colors.white,
          ));
        } else {
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
      }
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
            skuList1.clear();
            _isLoading = false;
            batchNum = result['data']['batch_num'];
            batchNum1 = result['data']['batch_num'];
            description = result['data']['description'] ?? '';
            returnSt = result['data']['return_st'] ?? '';
            defaultDisposal = result['data']['default_disposal'] ?? '';

            for (var item in result['data']['skus']) {
              skuList.add(ReturnedSku.fromJson(item));
              skuList1.add(ReturnedSku.fromJson(item));
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
          // print(result['reason']);
          showWarnToast(result['reason'].join(","));
          setState(() {
            resultShow.add({
              "status": false,
              "show": result['reason'].join(","),
              "num": newShipmentNum
            });
            clear();
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
        resultShow.add({"status": false, "show": e.toString()});
        clear();
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
      clear();
    });
  }

  void _reshelf() async {
    dynamic result;
    setState(() {
      canSubmit = false; // 防止重复提交
    });
    if (returnSt == "wrong_packing" || returnSt == "wrong_consignor") {
      _alertDialog("Reshelf", returnSt);
      clear();
    } else {
      try {
        if (num != null && num != "") {
          clear();
          String newShipmentNum = matchShipmentNum(num!);
          HiNavigator.getInstance()
              .onJumpTo(RouteStatus.returnedNewShelf, args: {
            "returnedNewShelfBatchNum": batchNum1,
            "returnedNewShelfShpmtNum": newShipmentNum,
            "returnedNewShelfDepotCode": depotCode
          });
        }
      } catch (e) {
        setState(() {
          resultShow.add({"status": false, "show": e.toString()});
          clear();
        });
        player.play('sounds/alert.mp3');
        showWarnToast(e.toString());
      }
    }
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  void _changePacking() async {
    dynamic result;
    setState(() {
      canSubmit = false; // 防止重复提交
    });
    if (returnSt == "wrong_packing" || returnSt == "wrong_consignor") {
      _alertDialog("New Packing", returnSt);
      clear();
    } else {
      try {
        if (num != null && num != "") {
          clear();
          String newShipmentNum = matchShipmentNum(num!);
          HiNavigator.getInstance()
              .onJumpTo(RouteStatus.returnedBrokenPackage, args: {
            "returnedBrokenPackageBatchNum": batchNum1,
            "returnedBrokenPackageShpmtNum": newShipmentNum,
            "returnedBrokenPackageDepotCode": depotCode,
            "returnedBrokenPackageDefaultDisposal": "reshelf_as_spare",
            "returnedBrokenPackageSkuList": skuList1
          });
        }
      } catch (e) {
        setState(() {
          resultShow.add({"status": false, "show": e.toString()});
          clear();
        });
        player.play('sounds/alert.mp3');
        showWarnToast(e.toString());
      }
    }
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  void _abandon() async {
    dynamic result;
    setState(() {
      canSubmit = false; // 防止重复提交
    });
    if (returnSt == "wrong_shipment") {
      _alertDialog("Abandon", returnSt);
      clear();
    } else {
      try {
        if (num != null && num != "") {
          clear();
          String newShipmentNum = matchShipmentNum(num!);
          HiNavigator.getInstance()
              .onJumpTo(RouteStatus.returnedBrokenPackage, args: {
            "returnedBrokenPackageBatchNum": batchNum1,
            "returnedBrokenPackageShpmtNum": newShipmentNum,
            "returnedBrokenPackageDepotCode": depotCode,
            "returnedBrokenPackageDefaultDisposal": "abandon",
            "returnedBrokenPackageSkuList": skuList1
          });
        }
      } catch (e) {
        setState(() {
          resultShow.add({"status": false, "show": e.toString()});
          clear();
        });
        player.play('sounds/alert.mp3');
        showWarnToast(e.toString());
      }
    }
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  void clear() {
    _isLoading = false;
    skuList.clear();
    batchNum = "";
    description = "";
    returnSt = "";
    canSubmit = false;
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
        result = await ReturnedDao.scan(newShipmentNum, depotCode);
        if (result["status"] == "succ") {
          setState(() {
            var now = DateTime.now();
            resultShow.add({
              "status": true,
              "show":
                  "${now.hour}:${now.minute}:${now.second}-Succeeded! Num:$newShipmentNum"
            });
            clear();
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
            resultShow
                .add({"status": false, "show": result['reason'].join(",")});
            clear();
          });
          player.play('sounds/alert.mp3');
          showWarnToast(result['reason'].join(","));
        }
      }
    } catch (e) {
      setState(() {
        resultShow.add({"status": false, "show": e.toString()});
        clear();
      });
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  _alertDialog(String choice, String rs) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("This package is $rs, can not <$choice>"),
            actions: [
              MaterialButton(
                  onPressed: () {
                    Navigator.pop(context, "cancel");
                  },
                  child:
                      const Text("Cancel", style: TextStyle(color: primary))),
            ],
          );
        });
  }
}
