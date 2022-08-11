import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uri_to_file/uri_to_file.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/authority.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/loading_container.dart';
import 'package:wms_app/widget/login_button.dart';
import 'package:audioplayers/audioplayers.dart';

class ReturnedPhotoPage extends StatefulWidget {
  final ReturnedParcel returnedParcel;
  final String photoFrom;
  const ReturnedPhotoPage(this.returnedParcel, this.photoFrom, {Key? key})
      : super(key: key);

  @override
  State<ReturnedPhotoPage> createState() => _ReturnedPhotoPageState();
}

class _ReturnedPhotoPageState extends HiState<ReturnedPhotoPage> {
  List<File> _images = [];
  bool submitEnable = false;
  bool isBoken = false;
  AudioCache player = AudioCache();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isBoken = widget.returnedParcel.isBroken!;
    });

    if (widget.returnedParcel.attachment != null) {
      _getCacheImages();
    }
  }

  _getCacheImages() async {
    setState(() {
      _isLoading = true;
    });
    for (var element in widget.returnedParcel.attachment!) {
      var response = await Dio().get("http://$auth${element['path']}",
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 100);
      // print(result);
      if (result['isSuccess'] == true) {
        File file = await toFile(result['filePath']);
        setState(() {
          _images.add(file);
          submitEnable = true;
        });
      }
    }
    setState(() {
      _isLoading = false;
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
        submitEnable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Pictures'),
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
      subtitle: Text("${widget.returnedParcel.batchNum}"),
    ));
    widgets.add(ListTile(
      title: const Text("Order Num: "),
      subtitle: Text("${widget.returnedParcel.orderNum}"),
    ));
    widgets.add(ListTile(
      title: const Text("Shipment Num: "),
      subtitle: Text("${widget.returnedParcel.shpmtNum}"),
    ));
    widgets.add(ListTile(
      title: const Text("Return Num: "),
      subtitle: Text("${widget.returnedParcel.roNum}"),
    ));
    widgets.add(ListTile(
      title: const Text("Unpack when taking pictures?"),
      subtitle: widget.returnedParcel.unpackPhoto == true
          ? Text(
              "Yes.${widget.returnedParcel.status == 'in_process_photo' ? '(Apply for unpacking photos)' : ''}",
              style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            )
          : const Text("No."),
    ));
    for (var element in widget.returnedParcel.returnedSku!) {
      widgets.add(Card(
        child: Column(
          children: [
            ListTile(
              title: Text("${element['sku_code']}, ${element['barcode']}"),
              subtitle: Text(
                  "name: ${element['foreign_name']}, quantity: ${element['quantity']}"),
            )
          ],
        ),
      ));
    }
    widgets.add(ListTile(
      trailing: CupertinoSwitch(
          value: isBoken,
          onChanged: (bool val) {
            setState(() {
              isBoken = val;
              if (_images.isEmpty) {
                submitEnable = false;
              } else {
                submitEnable = true;
              }
            });
          }),
      title: const Text("Is Broken?"),
      subtitle: const Text("Click the switch if parcel is broken."),
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
        'Upload',
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

      var result = await ReturnedDao.uploadPictures(
          widget.returnedParcel.id, attachments, isBoken);
      setState(() {
        _isLoading = false;
      });
      if (result['status'] == "succ") {
        showToast("Upload Pictures Successful");
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
    if (widget.photoFrom == "list") {
      HiNavigator.getInstance().onJumpTo(RouteStatus.returnedNeedPhoto);
    } else if (widget.photoFrom == "scan") {
      HiNavigator.getInstance().onJumpTo(RouteStatus.returnedScan,
          args: {"returnPageFrom": "photo"});
    } else if (widget.photoFrom == "receive") {
      HiNavigator.getInstance().onJumpTo(RouteStatus.inboundReceive);
    }
  }
}
