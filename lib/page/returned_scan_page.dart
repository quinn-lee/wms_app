import 'package:flutter/material.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/appbar.dart';
import 'package:wms_app/widget/scan_input.dart';

class ReturnedScanPage extends StatefulWidget {
  const ReturnedScanPage({Key? key}) : super(key: key);

  @override
  State<ReturnedScanPage> createState() => _ReturnedScanPageState();
}

class _ReturnedScanPageState extends State<ReturnedScanPage> {
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? num;

  @override
  void initState() {
    textEditingController.addListener(() {
      print("controller: ${textEditingController.text}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar("Returned Scan", "", () {}),
        body: Container(
          child: ListView(
            children: [
              ScanInput(
                "Barcode",
                "Scan Reterned parcel's barcode",
                focusNode,
                textEditingController,
                onChanged: (text) {
                  num = text;
                  print("num: $num");
                },
                onSubmitted: (text) {
                  _send();
                },
                focusChanged: (bool hasFocus) {
                  if (!hasFocus) {}
                },
              ),
            ],
          ),
        ));
  }

  void _send() async {
    dynamic result;
    try {
      if (num != null && num != "") {
        result = await ReturnedDao.scan(num!);
        print(result);
        if (result["status"] == "succ") {
          print("Scan successful");
          showToast("Scan Successful");
        } else {
          print("Scan fail");
          showWarnToast(result['reason'].join(","));
        }
      }
    } catch (e) {
      print(e);
      showWarnToast(e.toString());
    }
    textEditingController.clear();
    FocusScope.of(context).requestFocus(focusNode);
  }
}
