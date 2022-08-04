import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/fba_detach_dao.dart';
import 'package:wms_app/model/fba_detach_parcel.dart';
import 'package:wms_app/util/color.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/scan_input.dart';

class FbaDetachCurrentPage extends StatefulWidget {
  const FbaDetachCurrentPage({Key? key}) : super(key: key);

  @override
  State<FbaDetachCurrentPage> createState() => _FbaDetachCurrentPageState();
}

class _FbaDetachCurrentPageState extends HiState<FbaDetachCurrentPage> {
  List<FbaDetachParcel> parcelList = [];
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? num;
  bool _isLoading = false;
  AudioCache player = AudioCache();

  @override
  void initState() {
    super.initState();
    loadData();
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
        appBar: appBar("Fba Detach Current List", "", () {}),
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
      "Scan Fba Detach parcel's shipment no",
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
    for (var element in parcelList) {
      widgets.add(ListTile(
        title: Text("${element.identifier}, ${element.account ?? ''}"),
        subtitle: const Text("Long press here to show skus info"),
        trailing: const Icon(Icons.clear),
        onTap: () {
          _alertDelete(element.id);
        },
        onLongPress: () {
          _showSkuList(element.skus!);
        },
      ));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    return widgets;
  }

  void loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      dynamic result;
      if (num != null && num != "") {
        result = await FbaDetachDao.current(shipmentNum: num);
      } else {
        result = await FbaDetachDao.current();
      }
      if (result['status'] == "succ") {
        setState(() {
          parcelList.clear();
          for (var item in result['data']) {
            parcelList.add(FbaDetachParcel.fromJson(item));
          }
          _isLoading = false;
        });
      } else {
        showWarnToast(result['reason'].join(","));
        setState(() {
          _isLoading = false;
          parcelList.clear();
        });
      }
    } catch (e) {
      showWarnToast(e.toString());
      setState(() {
        _isLoading = false;
        parcelList.clear();
      });
    }
    if (mounted) {
      textEditingController.clear(); // 清除搜索栏
      FocusScope.of(context).requestFocus(focusNode); //聚焦
    }
  }

  _alertDelete(int id) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:
                const Text("You will delete this Fba detach parcel, confirm?"),
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
                    delete(id);
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

  // 删除
  void delete(int id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      dynamic result;
      result = await FbaDetachDao.delete(id);
      if (result['status'] == "succ") {
        setState(() {
          parcelList.clear();
          _isLoading = false;
          showToast("Delete successful");
          player.play('sounds/success01.mp3');
          num = null;
          // 重新加载数据
          loadData();
        });
      } else {
        showWarnToast(result['reason'].join(","));
        player.play('sounds/alert.mp3');
        setState(() {
          _isLoading = false;
          num = null;
        });
      }
    } catch (e) {
      showWarnToast(e.toString());
      player.play('sounds/alert.mp3');
      setState(() {
        num = null;
        parcelList.clear();
      });
    }
  }

  // 展示sku信息
  _showSkuList(List skus) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("SKU Summary"),
            content: _buildTable(skus),
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

  Widget _buildTable(List skuList) {
    List<DataRow> rows = [];
    for (var element in skuList) {
      rows.add(DataRow(cells: [
        DataCell(
            SizedBox(width: 120, child: Text(element['barcode'].toString()))),
        DataCell(
            SizedBox(width: 35, child: Text(element['quantity'].toString()))),
      ]));
    }
    return DataTable(columns: const [
      DataColumn(label: SizedBox(width: 120, child: Text("Barcode"))),
      DataColumn(label: SizedBox(width: 35, child: Text("QTY")))
    ], rows: rows);
  }
}
