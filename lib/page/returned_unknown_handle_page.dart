import 'dart:io';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/account_dao.dart';
import 'package:wms_app/http/dao/depot_dao.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/scan_input.dart';

class ReturnedUnknownHandlePage extends StatefulWidget {
  final String returnedShpmtNum;
  const ReturnedUnknownHandlePage(this.returnedShpmtNum, {Key? key})
      : super(key: key);

  @override
  State<ReturnedUnknownHandlePage> createState() =>
      _ReturnedUnknownHandlePageState();
}

class _ReturnedUnknownHandlePageState
    extends HiState<ReturnedUnknownHandlePage> {
  List<DropdownMenuItem<String>> depots = [];
  List<DropdownMenuItem<String>> accounts = [];
  String? depotCode;
  String? accountId;
  String? disposalMemo;
  String? shelfNum;
  String? skuNum;
  int quantity = 1;
  String? category;
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController1 = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  final TextEditingController textEditingController2 = TextEditingController();
  FocusNode focusNode2 = FocusNode();
  final TextEditingController textEditingController3 = TextEditingController();
  FocusNode focusNode3 = FocusNode();
  final TextEditingController textEditingController4 = TextEditingController();
  FocusNode focusNode4 = FocusNode();
  List<File> _images = [];
  bool submitEnable = false;
  List<Map> resultShow = [];
  AudioCache player = AudioCache();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });
    loadDepotData();
    loadConsignorData();
    setState(() {
      _isLoading = false;
    });
    textEditingController3.text = quantity.toString();
  }

  @override
  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
    focusNode1.dispose();
    textEditingController1.dispose();
    focusNode2.dispose();
    textEditingController2.dispose();
    focusNode3.dispose();
    textEditingController3.dispose();
    focusNode4.dispose();
    textEditingController4.dispose();
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

  void loadConsignorData() async {
    try {
      var result = await AccountDao.getConsignorList();
      if (result['status'] == "succ") {
        if (result['data'].length > 0) {
          for (var account in result['data']) {
            setState(() {
              accounts.add(DropdownMenuItem(
                  value: account['id'].toString(),
                  child: Text(account['abbr_code'] ?? '')));
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
        title: Text('${widget.returnedShpmtNum} Unknown Parcels'),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: LoadingContainer(
        cover: true,
        isLoading: _isLoading,
        child: ListView(
          children: _buildWidget(),
        ),
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

  // 组装页面
  List<Widget> _buildWidget() {
    List<Widget> widgets = [];

    widgets.add(ScanInput(
      "SKU Num",
      "Scan SKU Num",
      focusNode,
      textEditingController,
      onChanged: (text) {
        skuNum = text;
        checkInput();
      },
      onSubmitted: (text) {
        checkInput();
      },
    ));
    widgets.add(ScanInput(
      "Quantity",
      "",
      focusNode3,
      textEditingController3,
      onChanged: (text) {
        if (isNotEmpty(text) && text != "") {
          quantity = int.parse(text);
        } else {
          quantity = 1;
        }
        checkInput();
      },
      onSubmitted: (text) {
        checkInput();
      },
    ));
    widgets.add(_selectConsignor());
    widgets.add(const Divider(
      thickness: 32,
      color: Color(0XFFEEEEEE),
      height: 30,
    ));
    widgets.add(_selectDepot());
    widgets.add(ScanInput(
      "Shelf Num",
      "Shelf Num",
      focusNode1,
      textEditingController1,
      onChanged: (text) {
        shelfNum = text;
        checkInput();
      },
      onSubmitted: (text) {
        checkInput();
      },
    ));
    widgets.add(_selectCategory());
    widgets.add(ScanInput(
      "Disposal Memo",
      "Disposal Memo",
      focusNode4,
      textEditingController4,
      onChanged: (text) {
        disposalMemo = text;
        checkInput();
      },
      onSubmitted: (text) {
        checkInput();
      },
    ));
    widgets.add(const Divider(
      thickness: 32,
      color: Color(0XFFEEEEEE),
      height: 30,
    ));

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
        'Submit',
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

  // 仓库选项
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

  // 账号选项
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

  // 结果选项
  Widget _selectCategory() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15),
              width: 120,
              child: const Text(
                "Disposal Result",
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
                            checkInput();
                          });
                        },
                        items: const [
                  DropdownMenuItem(value: 'reshelf', child: Text('Reshelf')),
                  DropdownMenuItem(value: 'abandon', child: Text('Abandon')),
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

  // 验证输入是否可以提交
  void checkInput() {
    bool enable;
    if (isNotEmpty(depotCode) &&
        isNotEmpty(skuNum) &&
        (quantity > 0) &&
        isNotEmpty(accountId) &&
        isNotEmpty(category)) {
      if (category == "reshelf") {
        if (isNotEmpty(shelfNum)) {
          enable = true;
        } else {
          enable = false;
        }
      } else {
        enable = true;
      }
    } else {
      enable = false;
    }
    setState(() {
      submitEnable = enable;
    });
  }

  // 提交
  void upload() async {
    dynamic result;
    setState(() {
      submitEnable = false; // 防止重复提交
      _isLoading = true;
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
      result = await ReturnedDao.unknownReceiveAndFinish([
        {"sku_code": skuNum, "quantity": quantity}
      ], depotCode!, category!, accountId!, widget.returnedShpmtNum,
          disposalMemo: disposalMemo,
          shelfNum: shelfNum,
          attachment: attachments);
      if (result['status'] == "succ") {
        showToast("Unknown Returned Parcels $category Successful");
        setState(() {
          _isLoading = false;
          resultShow.add({
            "status": true,
            "show": "$category Success ! Sku Num : ${skuNum ?? ''}"
          });
        });
        player.play('sounds/success01.mp3');
      } else {
        showWarnToast(result['reason'].join(","));
        setState(() {
          _isLoading = false;
          resultShow.add({"status": false, "show": result['reason'].join(",")});
        });
        player.play('sounds/alert.mp3');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        resultShow.add({"status": false, "show": e.toString()});
      });
      player.play('sounds/alert.mp3');
      showWarnToast(e.toString());
    }
    HiNavigator.getInstance().onJumpTo(RouteStatus.returnedNewScan,
        args: {"newReturnPageFrom": "unknown"});
    // setState(() {
    //   _isLoading = false;
    //   abbrCode = "";
    //   textEditingController.clear();
    //   textEditingController1.clear();
    //   skuNum = "";
    //   textEditingController2.clear();
    //   category = null;
    //   quantity = 1;
    //   disposalMemo = "";
    //   shelfNum = "";
    //   textEditingController3.text = quantity.toString();
    //   textEditingController4.clear();
    //   _images.clear();
    // });
    // if (mounted) {
    //   textEditingController.clear();
    //   FocusScope.of(context).requestFocus(focusNode);
    // }
  }
}
