import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/model/returned_sku.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/color.dart';
import 'package:wms_app/util/string_util.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:wms_app/widget/scan_input.dart';

class ReturnedBrokenPackagePage extends StatefulWidget {
  final String batchNum;
  final String shpmtNum;
  final String depotCode;
  final String defaultDisposal;
  final List<ReturnedSku> skuList;
  const ReturnedBrokenPackagePage(this.batchNum, this.shpmtNum, this.depotCode,
      this.defaultDisposal, this.skuList,
      {Key? key})
      : super(key: key);

  @override
  State<ReturnedBrokenPackagePage> createState() =>
      _ReturnedBrokenPackagePageState();
}

class _ReturnedBrokenPackagePageState
    extends HiState<ReturnedBrokenPackagePage> {
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  String? shelfNum;
  List<File> _images = [];
  bool submitEnable = false;
  String? choice;
  String? actualDisposal;
  String? actualChoice;
  AudioCache player = AudioCache();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      choice = {
        "reshelf_as_spare": "New Packing",
        "abandon": "Abandon"
      }[widget.defaultDisposal];
      actualDisposal = widget.defaultDisposal;
      actualChoice = choice;
      if (widget.defaultDisposal == "reshelf_as_spare") {
        for (var ele in widget.skuList) {
          if (isEmpty(ele.defaultPackingMaterial)) {
            actualChoice = "Abandon";
            actualDisposal = "abandon";
          }
        }
        if (actualDisposal == "abandon") {
          Future.delayed(Duration.zero, () {
            _alertDialog(
                "Because the defulat packing material of this package's sku is blank, the handled way is changed to abandonment!",
                "Handle Memo");
          });
        }
      }
    });
  }

  Future getImage(bool isTakePhoto) async {
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: isTakePhoto ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 10); // 图片压缩
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
        checkInput();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handle Broken Packages'),
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
          child: ListView(children: _buildListView())),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Select Pictures',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  List<Widget> _buildListView() {
    List<Widget> widgets = [];

    widgets.add(ListTile(
      title: const Text("Batch Num: "),
      subtitle: Text(widget.batchNum),
    ));
    widgets.add(ListTile(
      title: const Text("Shipment Num: "),
      subtitle: Text(widget.shpmtNum),
    ));
    widgets.add(ListTile(
      title: const Text("Original Photos: "),
      subtitle: _images.isEmpty
          ? const Text(
              "No Photos",
              style: TextStyle(color: Colors.red),
            )
          : const Text(""),
    ));
    widgets.add(Center(
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: _genImages(),
      ),
    ));
    widgets.add(const Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Divider(
        height: 1,
        color: Colors.grey,
      ),
    ));
    widgets.add(ListTile(
      title: RichText(
        text: TextSpan(
            text: "handled way: ",
            style: const TextStyle(color: Colors.black, fontSize: 18),
            children: <TextSpan>[
              TextSpan(
                  text: actualChoice!,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold))
            ]),
      ),
      subtitle: actualDisposal == widget.defaultDisposal
          ? const Text("")
          : const Text(
              "Because the defulat packing material of this package's sku is blank, the handled way is changed to abandonment!"),
    ));

    if (widget.defaultDisposal == "reshelf_as_spare") {
      for (var element in widget.skuList) {
        widgets.add(Card(
          child: Column(
            children: [
              ListTile(
                title: Text("${element.skuCode}, ${element.barcode}"),
                subtitle: RichText(
                  text: TextSpan(
                      text: "Default Packing Material: ",
                      style: const TextStyle(color: Colors.grey),
                      children: <TextSpan>[
                        TextSpan(
                            text: element.defaultPackingMaterial,
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold))
                      ]),
                ),
              )
            ],
          ),
        ));
      }
    }
    if (actualDisposal == "reshelf_as_spare") {
      widgets.add(ScanInput(
        "Shelf",
        "Scan Shelf's Barcode",
        focusNode,
        textEditingController,
        onChanged: (text) {
          shelfNum = text;
          checkInput();
        },
      ));
    }

    widgets.add(Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: LoginButton(
        "Submit",
        1,
        enable: submitEnable,
        onPressed: upload,
      ),
    ));
    return widgets;
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
                    checkInput();
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

  void checkInput() {
    bool enable;
    if (actualDisposal == "reshelf_as_spare") {
      if (isNotEmpty(shelfNum) && _images.isNotEmpty) {
        enable = true;
      } else {
        enable = false;
      }
    } else {
      if (_images.isNotEmpty) {
        enable = true;
      } else {
        enable = false;
      }
    }
    setState(() {
      submitEnable = enable;
    });
  }

  _alertDialog(String message, String title) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              //MaterialButton(
              //    onPressed: () {
              //      Navigator.pop(context, "cancel");
              //    },
              //    child:
              //        const Text("Cancel", style: TextStyle(color: primary))),
              MaterialButton(
                  onPressed: () {
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

  void upload() async {
    setState(() {
      submitEnable = false; // 防止重复提交
      _isLoading = true;
    });
    List attachments = [];
    int index = 1;
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
      // print(attachments);

      var result = await ReturnedDao.receiveAndFinish(
          widget.shpmtNum, widget.depotCode, actualDisposal!,
          shelfNum: shelfNum, attachment: attachments);
      setState(() {
        _isLoading = false;
      });
      if (result['status'] == "succ") {
        showToast("${actualChoice!} Successful");
        player.play('sounds/success01.mp3');
      } else {
        showWarnToast(result['reason'].join(","));
        player.play('sounds/alert.mp3');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // print(e);
      showWarnToast(e.toString());
      player.play('sounds/alert.mp3');
    }
    HiNavigator.getInstance().onJumpTo(RouteStatus.returnedNewScan);
  }
}
