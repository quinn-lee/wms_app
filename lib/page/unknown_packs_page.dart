import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/account_dao.dart';
import 'package:wms_app/http/dao/depot_dao.dart';
import 'package:wms_app/http/dao/inbound_dao.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/scan_input.dart';

class UnknownPacksPage extends StatefulWidget {
  const UnknownPacksPage({Key? key}) : super(key: key);

  @override
  State<UnknownPacksPage> createState() => _UnknownPacksPageState();
}

class _UnknownPacksPageState extends HiState<UnknownPacksPage> {
  List<DropdownMenuItem<String>> depots = [];
  List<DropdownMenuItem<String>> accounts = [];
  String? depotCode;
  String? category;
  String? accountId;
  String? num;
  String? shipmentNum;
  String? skuNum;
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController1 = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  final TextEditingController textEditingController2 = TextEditingController();
  FocusNode focusNode2 = FocusNode();
  List<File> _images = [];
  bool submitEnable = false;
  List<Map> resultShow = [];
  AudioCache player = AudioCache();

  @override
  void initState() {
    super.initState();
    loadDepotData();
    loadConsignorData();
  }

  void loadDepotData() async {
    try {
      var result = await DepotDao.getDepotList();
      if (result['status'] == "succ") {
        if (result['data'].length > 0) {
          for (var depot in result['data']) {
            setState(() {
              depots.add(DropdownMenuItem(
                  value: depot['depot_code'],
                  child: Text(depot['depot_code'])));
            });
          }
          setState(() {
            depotCode = result['data'][0]['depot_code'];
          });
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

  void loadConsignorData() async {
    try {
      var result = await AccountDao.getConsignorList();
      if (result['status'] == "succ") {
        if (result['data'].length > 0) {
          for (var account in result['data']) {
            setState(() {
              accounts.add(DropdownMenuItem(
                  value: account['id'].toString(),
                  child: Text(account['abbr_code'])));
            });
          }
        } else {
          showWarnToast("No Consignors Found");
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

  Future getImage(bool isTakePhoto) async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: isTakePhoto ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 10); // 图片压缩
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Unknown Parcels'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Select Pictures',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  _pickImage() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
            height: 160,
            child: Column(
              children: <Widget>[
                _item('Photo', true),
                _item('Select Pictures', false)
              ],
            )));
  }

  _item(String title, bool isTakePhoto) {
    return GestureDetector(
      child: ListTile(
        leading: Icon(isTakePhoto ? Icons.camera_alt : Icons.photo_library),
        title: Text(title),
        onTap: () => getImage(isTakePhoto),
      ),
    );
  }

  _genImages() {
    return _images.map((file) {
      return Stack(
        children: <Widget>[
          ClipRRect(
            //圆角效果
            borderRadius: BorderRadius.circular(5),
            child: Image.file(file, width: 120, height: 90, fit: BoxFit.fill),
          ),
          Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _images.remove(file);
                    if (_images.isEmpty) {
                      submitEnable = false;
                    }
                  });
                },
                child: ClipOval(
                  //圆角删除按钮
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.black54),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ))
        ],
      );
    }).toList();
  }

  List<Widget> _buildWidget() {
    List<Widget> widgets = [];
    widgets.add(ScanInput(
      "Scan No",
      "Scan Number",
      focusNode,
      textEditingController,
      onChanged: (text) {
        num = text;
        checkInput();
      },
      onSubmitted: (text) {
        _assignData();
        checkInput();
      },
    ));
    widgets.add(const Divider(
      thickness: 32,
      color: Color(0XFFEEEEEE),
      height: 30,
    ));
    widgets.add(_selectDepot());
    widgets.add(ScanInput(
      "Shipment Num",
      "Shipment Number",
      focusNode1,
      textEditingController1,
    ));
    widgets.add(ScanInput(
      "SKU/Serial Num",
      "SKU/Serial Number",
      focusNode2,
      textEditingController2,
    ));
    widgets.add(_selectCategory());
    widgets.add(_selectConsignor());
    widgets.add(ListTile(
      title: const Text("Pictures: "),
      subtitle: _images.isEmpty ? const Text("No Pictures") : const Text(""),
    ));
    widgets.add(Center(
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: _genImages(),
      ),
    ));
    widgets.add(Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: LoginButton(
        'Upload',
        1,
        enable: submitEnable,
        onPressed: upload,
      ),
    ));

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
      RegExp regDhl = RegExp(
          r"(^2222\d.*)|(^CD[a-zA-Z0-9]{11}$)|(^0034\d{16}$)|(^13915023\d{6}$)|(^1Z[a-zA-Z0-9]{16}$)");
      if (regDhl.hasMatch(num!)) {
        shipmentNum = num;
        textEditingController1.text = num!;
      } else {
        if (num!.substring(0, 1) == '%') {
          if (num!.length >= 23) {
            shipmentNum = num!.substring(8, 22);
            textEditingController1.text = num!.substring(8, 22);
          } else {
            skuNum = num;
            textEditingController2.text = num!;
          }
        } else {
          skuNum = num;
          textEditingController2.text = num!;
        }
      }
    }
    if (mounted) {
      textEditingController.clear();
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

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
                          });
                          checkInput();
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

  Widget _selectCategory() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15),
              width: 120,
              child: const Text(
                "Category",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        value: category,
                        elevation: 12,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.black),
                        iconEnabledColor: Colors.green,
                        onChanged: (newValue) {
                          setState(() {
                            category = newValue!;
                          });
                        },
                        items: const [
                  DropdownMenuItem(value: 'a', child: Text('111')),
                  DropdownMenuItem(value: 'b3', child: Text('222')),
                  DropdownMenuItem(value: 'b4', child: Text('333')),
                  DropdownMenuItem(value: 'return', child: Text('444')),
                ])))
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

  Widget _selectConsignor() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15),
              width: 120,
              child: const Text(
                "Account",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        value: accountId,
                        elevation: 12,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.black),
                        iconEnabledColor: Colors.green,
                        onChanged: (newValue) {
                          setState(() {
                            accountId = newValue!;
                          });
                        },
                        items: accounts)))
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

  void checkInput() {
    bool enable;
    if (isNotEmpty(depotCode) && isNotEmpty(shipmentNum)) {
      enable = true;
    } else {
      enable = false;
    }
    setState(() {
      submitEnable = enable;
    });
  }

  void upload() async {
    dynamic result;
    setState(() {
      submitEnable = false; // 防止重复提交
    });
    List attachments = [];
    int index = 0;
    try {
      for (var img in _images) {
        final bytes = img.readAsBytesSync();
        // print(bytes.lengthInBytes);
        attachments.add({
          "i": index++,
          "filename": img.path.split("/").last,
          "content": base64.encode(bytes),
        });
      }
      result = await InboundDao.registerUnknownParcel(
          depotCode!, skuNum, shipmentNum!, category, accountId, attachments);
      if (result['status'] == "succ") {
        showToast("Register Unknown Parcels Successful");
        setState(() {
          resultShow.add({
            "status": true,
            "show":
                "Register Success ! Serial Num : ${skuNum ?? ''} , Shipment Num : ${shipmentNum ?? ''}"
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
      shipmentNum = "";
      textEditingController1.text = "";
      skuNum = "";
      textEditingController2.text = "";
      category = null;
      accountId = null;
      _images.clear();
    });
  }
}
