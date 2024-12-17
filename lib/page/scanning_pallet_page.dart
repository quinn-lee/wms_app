import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/pallet_dao.dart';
import 'package:wms_app/util/color.dart';
import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/scan_input.dart';

class ScanningPalletPage extends StatefulWidget {
  const ScanningPalletPage({Key? key}) : super(key: key);

  @override
  State<ScanningPalletPage> createState() => _ScanningPalletPageState();
}

class _ScanningPalletPageState extends HiState<ScanningPalletPage> {
  AudioCache player = AudioCache();
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController1 = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  final TextEditingController textEditingController2 = TextEditingController();
  FocusNode focusNode2 = FocusNode();
  String? palletNum;
  String? parcelNum1;
  String parcelNum2 = "";
  int quantity = 0;
  List parcelNums = [];
  List<Map> resultShow = [];
  bool _isLoading = false;
  bool canSubmit = false;
  @override
  void initState() {
    super.initState();
  }

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
        appBar: appBar("Pallet Scanning", "", () {}),
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
    widgets.add(Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            FractionallySizedBox(
                widthFactor: 0.45,
                child: ListTile(
                  title: Text("Added Parcel's QTY: $quantity"),
                  subtitle: const Text(""),
                )),
            LoginButton(
              'Parcels Info',
              0.45,
              enable: true,
              onPressed: _showParcelInfo,
            ),
          ],
        )));
    widgets.add(ScanInput(
      "Truck No",
      "Scan Truck No",
      focusNode,
      textEditingController,
      onChanged: (text) {
        palletNum = text;
        checkInput();
      },
      onSubmitted: (text) {
        _scanningPalletNum();
      },
    ));
    widgets.add(const Divider(
      height: 1,
      color: Colors.white,
    ));
    widgets.add(ScanInput(
      "Barcode No1",
      "Scan Barcode No1",
      focusNode1,
      textEditingController1,
      onChanged: (text) {
        parcelNum1 = text;
        checkInput();
      },
      onSubmitted: (text) {
        _scanningParcelNum1();
      },
    ));
    widgets.add(ScanInput(
        "Barcode No2", "Scan Barcode No2", focusNode2, textEditingController2,
        onChanged: (text) {
      parcelNum2 = text;
      checkInput();
    }));
    widgets.add(Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: LoginButton(
        'Submit',
        1,
        enable: canSubmit,
        onPressed: _scanned,
      ),
    ));

    for (var element in resultShow.reversed) {
      widgets.add(InkWell(
          onTap: () {
            if (element['category'] == "success") {
              _alertDelete(element['parcelNum1'], element['parcelNum2']);
            }
          },
          child: ListTile(
            title: Text(
              element['show'],
              style: const TextStyle(color: Colors.white),
            ),
            tileColor: {
              "success": const Color(0xFF4e72b8),
              "success1": const Color(0xFF6a6da9),
              "fail": const Color(0xFFf15b6c)
            }[element['category']],
          )));
      widgets.add(const Divider(
        height: 1,
        color: Colors.white,
      ));
    }
    return widgets;
  }

  void checkInput() {
    bool enable;
    if (isNotEmpty(palletNum) && isNotEmpty(parcelNum1)) {
      enable = true;
    } else {
      enable = false;
    }
    setState(() {
      canSubmit = enable;
    });
  }

  // 展示汇总信息
  _showParcelInfo() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Parcels Summary"),
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
    for (final value in parcelNums) {
      rows.add(DataRow(cells: [
        DataCell(SizedBox(
            width: 160,
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 12),
            )))
      ]));
    }
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(columns: const [
              DataColumn(
                  label: SizedBox(
                width: 160,
                child: Text("Parcel Num"),
              ))
            ], rows: rows)));
  }

  _alertDelete(deleteNum1, deleteNum2) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("You will delete this parcel, confirm?"),
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
                    _deleteParcel(deleteNum1, deleteNum2);
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

  void _deleteParcel(deleteNum1, deleteNum2) async {
    setState(() {
      _isLoading = true;
    });
    dynamic result;
    try {
      if (palletNum != null &&
          palletNum != "" &&
          deleteNum1 != null &&
          deleteNum1 != "") {
        if (deleteNum2 == "") {
          deleteNum2 = "null";
        }
        result =
            await PalletDao.deleteParcel(palletNum!, deleteNum1!, deleteNum2);
        if (result["status"] == "succ") {
          setState(() {
            _isLoading = false;
            quantity = result["data"]['quantity'];
            parcelNums = result["data"]['parcel_nums'];
            var now = DateTime.now();
            String show = "";
            show =
                "${now.hour}:${now.minute}:${now.second}-Delete Successed! Num:$deleteNum1,$deleteNum2";

            resultShow.add({"category": "success1", "show": show});
            player.play('sounds/success01.mp3');
          });
        } else {
          setState(() {
            _isLoading = false;
            resultShow
                .add({"category": "fail", "show": result['reason'].join(",")});
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
        resultShow.add({"category": "fail", "show": e.toString()});
      });
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    if (mounted) {
      textEditingController1.clear();
      textEditingController2.clear();
      FocusScope.of(context).requestFocus(focusNode1);
    }
  }

  void _scanningPalletNum() async {
    setState(() {
      _isLoading = true;
    });
    dynamic result;
    try {
      if (palletNum != null && palletNum != "") {
        result = await PalletDao.getPalletInfo(palletNum!);
        if (result["status"] == "succ") {
          setState(() {
            _isLoading = false;
            quantity = result["data"]['quantity'];
            parcelNums = result["data"]['parcel_nums'];
          });
        } else {
          setState(() {
            _isLoading = false;
            quantity = 0;
            parcelNums = [];
          });
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        resultShow.add({"category": "fail", "show": e.toString()});
      });
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    if (mounted) {
      FocusScope.of(context).requestFocus(focusNode1);
    }
  }

  void _scanningParcelNum1() async {
    if (mounted) {
      FocusScope.of(context).requestFocus(focusNode2);
    }
  }

  void _scanned() async {
    setState(() {
      _isLoading = true;
    });
    dynamic result;
    try {
      if (palletNum != null &&
          palletNum != "" &&
          parcelNum1 != null &&
          parcelNum1 != "") {
        result = await PalletDao.scanning(palletNum!, parcelNum1!, parcelNum2);
        if (result["status"] == "succ") {
          setState(() {
            _isLoading = false;
            var now = DateTime.now();
            quantity = result["data"]['quantity'];
            parcelNums = result["data"]['parcel_nums'];
            String show = "";
            show =
                "${now.hour}:${now.minute}:${now.second}-Successed! Num:$parcelNum1,$parcelNum2 , Click to Delete This Parcel";

            resultShow.add({
              "category": "success",
              "show": show,
              "parcelNum1": parcelNum1,
              "parcelNum2": parcelNum2
            });
            parcelNum1 = null;
            parcelNum2 = "";
            player.play('sounds/success01.mp3');
          });
        } else {
          setState(() {
            _isLoading = false;
            resultShow
                .add({"category": "fail", "show": result['reason'].join(",")});
          });
          player.play('sounds/alert.mp3');
          parcelNum1 = null;
          parcelNum2 = "";
          showWarnToast(result['reason'].join(","));
        }
      } else {
        setState(() {
          _isLoading = false;
          resultShow.add({
            "category": "fail",
            "show": "Please Scan Pallet Num And Parcel Num"
          });
        });
        player.play('sounds/alert.mp3');
        parcelNum1 = null;
        parcelNum2 = "";
        showWarnToast("Please Scan Pallet Num And Parcel Num");
      }
      setState(() {
        parcelNum1 = null;
        parcelNum2 = "";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        resultShow.add({"category": "fail", "show": e.toString()});
      });
      player.play('sounds/alert.mp3');
      parcelNum1 = null;
      parcelNum2 = "";
      showWarnToast(e.toString());
    }
    if (mounted) {
      textEditingController1.clear();
      textEditingController2.clear();
      FocusScope.of(context).requestFocus(focusNode1);
    }
  }
}
