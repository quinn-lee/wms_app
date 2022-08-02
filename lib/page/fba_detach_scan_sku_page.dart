import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/fba_detach_dao.dart';
import 'package:wms_app/model/fba_detach_parcel.dart';
import 'package:wms_app/model/fba_detach_sku.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/color.dart';
import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/cancel_button.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/login_input.dart';
import 'package:wms_app/widget/scan_input.dart';

class FbaDetachScanSkuPage extends StatefulWidget {
  final FbaDetachParcel fdp;
  const FbaDetachScanSkuPage(this.fdp, {Key? key}) : super(key: key);

  @override
  State<FbaDetachScanSkuPage> createState() => _FbaDetachScanSkuPageState();
}

class _FbaDetachScanSkuPageState extends HiState<FbaDetachScanSkuPage> {
  List<FbaDetachSku> skuList = [];
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController tec1 = TextEditingController();
  final TextEditingController tec2 = TextEditingController();
  final TextEditingController tec3 = TextEditingController();
  final TextEditingController tec4 = TextEditingController();
  final TextEditingController tec5 = TextEditingController();
  final TextEditingController tec6 = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? num;
  int? accountId;
  String? account;
  int? quantity;
  String? length;
  String? width;
  String? height;
  String? weight;
  bool isSelected = false;
  bool _isLoading = false;
  bool canSubmit = false;
  AudioCache player = AudioCache();
  List<Map> resultShow = [];
  Map sumList = {};

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
    tec1.dispose();
    tec2.dispose();
    tec3.dispose();
    tec4.dispose();
    tec5.dispose();
    tec6.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          appBar("Fba Detach Add Sku", "", () {}, backPressed: _alertReturn),
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
      title: Text(
          "Shipment Num: ${widget.fdp.identifier}, ${widget.fdp.account ?? ''}"),
      subtitle: Text(widget.fdp.updatedAt!.substring(0, 10)),
    ));
    widgets.add(Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            LoginButton(
              'SKU Summary',
              0.45,
              enable: true,
              onPressed: _showSumList,
            ),
            CancelButton(
              'Quit',
              0.45,
              enable: true,
              onPressed: _alertReturn,
            ),
          ],
        )));
    widgets.add(ScanInput(
      "Barcode",
      "Scan sku's barcode",
      focusNode,
      textEditingController,
      onChanged: (text) {
        num = text;
      },
      onSubmitted: (text) {
        loadData();
      },
    ));

    widgets.add(const Divider(
      height: 1,
      color: Colors.white,
    ));
    for (var element in skuList) {
      widgets.add(ListTile(
        title: Text("SkuCode: ${element.skuCode}, ${element.account ?? ''}"),
        subtitle: Text(
            "length: ${element.length}, width: ${element.width}, height: ${element.height}, weight: ${element.weight}"),
        trailing: const Icon(Icons.check_circle_outline),
        onTap: () {
          setState(() {
            isSelected = true;
            accountId = element.accountId;
            account = element.account;
            tec6.text = account ?? '';
            quantity = 1;
            tec1.text = quantity.toString();
            length = element.length;
            tec2.text = length ?? '';
            width = element.width;
            tec3.text = width ?? '';
            height = element.height;
            tec4.text = height ?? '';
            weight = element.weight;
            tec5.text = weight ?? '';
            skuList.clear();
            checkInput();
          });
        },
      ));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    if (isSelected) {
      if (isEmpty(length) ||
          length == null ||
          isEmpty(width) ||
          width == null ||
          isEmpty(height) ||
          height == null ||
          isEmpty(weight) ||
          weight == null) {
        widgets.add(const ListTile(
          title: Text(
            "Please fill in the measurement data first, then submit",
            style: TextStyle(color: Colors.white),
          ),
          tileColor: Color(0xFFf7acbc),
        ));
        widgets.add(const Divider(
          height: 1,
          color: Colors.white,
        ));
      }
      widgets.add(
          LoginInput("Sku Owner", "", tec6, enabled: false, autofocus: false));
      widgets.add(LoginInput("Length", "", tec2, onChanged: (text) {
        length = text;
        checkInput();
      }, keyboardType: TextInputType.number, autofocus: false));
      widgets.add(LoginInput("Width", "", tec3, onChanged: (text) {
        width = text;
        checkInput();
      }, keyboardType: TextInputType.number, autofocus: false));
      widgets.add(LoginInput("Height", "", tec4, onChanged: (text) {
        height = text;
        checkInput();
      }, keyboardType: TextInputType.number, autofocus: false));
      widgets.add(LoginInput("Weight", "", tec5, onChanged: (text) {
        weight = text;
        checkInput();
      }, keyboardType: TextInputType.number, autofocus: false));
      widgets.add(LoginInput("Quantity", "", tec1, onChanged: (text) {
        if (isNotEmpty(text)) {
          quantity = int.parse(text);
        } else {
          quantity = null;
        }
        checkInput();
      }, keyboardType: TextInputType.number, autofocus: false));
      widgets.add(Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: LoginButton(
          "Submit",
          1,
          enable: canSubmit,
          onPressed: newSku,
        ),
      ));
    }

    for (var element in resultShow.reversed) {
      if (element['barcode'] != null) {
        widgets.add(ListTile(
          title: Text(
            element['show'],
            style: const TextStyle(color: Colors.white),
          ),
          tileColor: element['status']
              ? const Color(0xFF4e72b8)
              : const Color(0xFFf15b6c),
          onTap: () {
            _alertRollback(
                element['barcode'], element['quantity'], element['accountId']);
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

    return widgets;
  }

  // 查询sku信息
  void loadData() async {
    setState(() {
      _isLoading = true;
      isSelected = false;
    });
    try {
      dynamic result;
      if (num != null) {
        result = await FbaDetachDao.searchSku(num!);
      } else {
        setState(() {
          _isLoading = false;
        });
        showWarnToast("Please scan shipment num!");
      }
      if (result['status'] == "succ") {
        setState(() {
          skuList.clear();
          for (var item in result['data']) {
            skuList.add(FbaDetachSku.fromJson(item));
          }
          _isLoading = false;
        });
        if (result['data'].isEmpty) {
          showWarnToast("This barcode--$num has not been registered!");
          if (mounted) {
            textEditingController.clear();
            FocusScope.of(context).requestFocus(focusNode);
          }
          player.play('sounds/alert.mp3');
        }
      } else {
        showWarnToast(result['reason'].join(","));
        setState(() {
          _isLoading = false;
          skuList.clear();
        });
      }
    } catch (e) {
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
        skuList.clear();
      });
    }
  }

  void checkInput() {
    if (isNotEmpty(num) &&
        quantity != null &&
        quantity! > 0 &&
        accountId != null &&
        isNotEmpty(length) &&
        isNotEmpty(width) &&
        isNotEmpty(height) &&
        isNotEmpty(weight)) {
      setState(() {
        canSubmit = true;
      });
    } else {
      setState(() {
        canSubmit = false;
      });
    }
  }

  // 添加sku提交
  void newSku() async {
    setState(() {
      _isLoading = true;
      canSubmit = false;
    });
    try {
      dynamic result;
      Map data = {
        "barcode": num,
        "account_id": accountId,
        "quantity": quantity,
        "length": length,
        "width": width,
        "height": height,
        "weight": weight
      };
      result = await FbaDetachDao.addSku(widget.fdp.id, data);

      if (result['status'] == "succ") {
        setState(() {
          _isLoading = false;
          player.play('sounds/success01.mp3');
          var now = DateTime.now();
          resultShow.add({
            "status": true,
            "show":
                "${now.hour}:${now.minute}:${now.second}-Succeeded! Num:$num, Quantity: $quantity. Click here to roll back this operation.",
            "barcode": num,
            "quantity": quantity,
            "accountId": accountId
          });
          // 汇总信息
          if (sumList.containsKey(num!)) {
            sumList[num!] = sumList[num!] + quantity;
          } else {
            sumList[num!] = quantity;
          }
        });
      } else {
        showWarnToast(result['reason'].join(","));
        player.play('sounds/alert.mp3');
        setState(() {
          _isLoading = false;
          resultShow.add({"status": false, "show": result['reason'].join(",")});
        });
      }
    } catch (e) {
      showWarnToast(e.toString());
      player.play('sounds/alert.mp3');
      setState(() {
        _isLoading = false;
        resultShow.add({"status": false, "show": e.toString()});
      });
    }
    setState(() {
      isSelected = false;
      accountId = null;
      account = null;
      quantity = null;
      tec1.text = '';
      length = null;
      tec2.text = '';
      width = null;
      tec3.text = '';
      height = null;
      tec4.text = '';
      weight = null;
      tec5.text = '';
      skuList.clear();
      num = null;
    });
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  // 回退
  void rollback(String barcode, int quantity, int accountId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      dynamic result;
      Map data = {
        "barcode": barcode,
        "account_id": accountId,
        "quantity": -quantity,
      };
      result = await FbaDetachDao.addSku(widget.fdp.id, data);

      if (result['status'] == "succ") {
        setState(() {
          _isLoading = false;
          player.play('sounds/success01.mp3');
          var now = DateTime.now();
          resultShow.add({
            "status": true,
            "show":
                "${now.hour}:${now.minute}:${now.second}-Rollback Succeeded! Num:$barcode, Quantity: -$quantity.",
          });
          // 汇总信息
          if (sumList.containsKey(barcode)) {
            sumList[barcode] = sumList[barcode] - quantity;
          } else {
            sumList[barcode] = -quantity;
          }
        });
      } else {
        showWarnToast(result['reason'].join(","));
        player.play('sounds/alert.mp3');
        setState(() {
          _isLoading = false;
          resultShow.add({"status": false, "show": result['reason'].join(",")});
        });
      }
    } catch (e) {
      showWarnToast(e.toString());
      player.play('sounds/alert.mp3');
      setState(() {
        _isLoading = false;
        resultShow.add({"status": false, "show": e.toString()});
      });
    }
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  _alertRollback(String barcode, int quantity, int accountId) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "The number of this sku-$barcode will be reduced by $quantity, confirm?"),
            content: const Text(""),
            actions: [
              MaterialButton(
                  onPressed: () {
                    Navigator.pop(context, "cancel");
                  },
                  child:
                      const Text("Cancel", style: TextStyle(color: primary))),
              MaterialButton(
                  onPressed: () {
                    rollback(barcode, quantity, accountId);
                    Navigator.pop(context, "ok");
                  },
                  color: primary,
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          );
        });
  }

  // 展示汇总信息
  _showSumList() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("SKU Summary"),
            content: _buildTable(),
            actions: [
              MaterialButton(
                  onPressed: () {
                    Navigator.pop(context, "close");
                  },
                  child: const Text("Close", style: TextStyle(color: primary))),
            ],
          );
        });
  }

  Widget _buildTable() {
    List<DataRow> rows = [];
    sumList.forEach((key, value) {
      rows.add(DataRow(cells: [
        DataCell(Text(key.toString())),
        DataCell(Text(value.toString()))
      ]));
    });
    return DataTable(columns: const [
      DataColumn(label: Text("Barcode")),
      DataColumn(label: Text("Quantity"))
    ], rows: rows);
  }

  // 退出页面confirm
  _alertReturn() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
                "After exiting the page, the operation cannot be rolled back, are you sure?"),
            content: const Text(""),
            actions: [
              MaterialButton(
                  onPressed: () {
                    Navigator.pop(context, "cancel");
                  },
                  child:
                      const Text("Cancel", style: TextStyle(color: primary))),
              MaterialButton(
                  onPressed: () {
                    HiNavigator.getInstance()
                        .onJumpTo(RouteStatus.fbaDetachScan);
                    Navigator.pop(context, "ok");
                  },
                  color: primary,
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          );
        });
  }
}
