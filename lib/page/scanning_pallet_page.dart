import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/pallet_dao.dart';
import 'package:wms_app/util/color.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/loading_container.dart';
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
  String? palletNum;
  String? parcelNum;
  List<Map> resultShow = [];
  bool _isLoading = false;
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
    widgets.add(ScanInput(
      "Pallet No",
      "Scan Pallet No",
      focusNode,
      textEditingController,
      onChanged: (text) {
        palletNum = text;
        // print("num: $num");
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
      "Parcel No",
      "Scan Parcel No",
      focusNode1,
      textEditingController1,
      onChanged: (text) {
        parcelNum = text;
      },
      onSubmitted: (text) {
        _scanned();
      },
    ));

    for (var element in resultShow.reversed) {
      widgets.add(InkWell(
          onTap: () {
            if (element['category'] == "success") {
              _alertDelete(element['parcelNum']);
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

  _alertDelete(deleteNum) async {
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
                    _deleteParcel(deleteNum);
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

  void _deleteParcel(deleteNum) async {
    setState(() {
      _isLoading = true;
    });
    dynamic result;
    try {
      if (palletNum != null &&
          palletNum != "" &&
          deleteNum != null &&
          deleteNum != "") {
        result = await PalletDao.deleteParcel(palletNum!, deleteNum!);
        if (result["status"] == "succ") {
          setState(() {
            _isLoading = false;
            var now = DateTime.now();
            String show = "";
            show =
                "${now.hour}:${now.minute}:${now.second}-Delete Successed! Num:$deleteNum";

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
      FocusScope.of(context).requestFocus(focusNode1);
    }
  }

  void _scanningPalletNum() {
    if (mounted) {
      FocusScope.of(context).requestFocus(focusNode1);
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
          parcelNum != null &&
          parcelNum != "") {
        result = await PalletDao.scanning(palletNum!, parcelNum!);
        if (result["status"] == "succ") {
          setState(() {
            _isLoading = false;
            var now = DateTime.now();
            String show = "";
            show =
                "${now.hour}:${now.minute}:${now.second}-Successed! Num:$parcelNum, , Click to Delete This Parcel";

            resultShow.add(
                {"category": "success", "show": show, "parcelNum": parcelNum});
            parcelNum = null;
            player.play('sounds/success01.mp3');
          });
        } else {
          setState(() {
            _isLoading = false;
            resultShow
                .add({"category": "fail", "show": result['reason'].join(",")});
          });
          player.play('sounds/alert.mp3');
          parcelNum = null;
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
        parcelNum = null;
        showWarnToast("Please Scan Pallet Num And Parcel Num");
      }
      setState(() {
        parcelNum = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        resultShow.add({"category": "fail", "show": e.toString()});
      });
      player.play('sounds/alert.mp3');
      parcelNum = null;
      showWarnToast(e.toString());
    }
    if (mounted) {
      textEditingController1.clear();
      FocusScope.of(context).requestFocus(focusNode1);
    }
  }
}
