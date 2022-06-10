import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/http/dao/returned_dao.dart';
import 'package:wms_app/model/returned_parcel.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/util/toast.dart';
import 'package:wms_app/widget/login_button.dart';

class ReturnedPhotoPage extends StatefulWidget {
  final ReturnedParcel returnedParcel;
  const ReturnedPhotoPage(this.returnedParcel, {Key? key}) : super(key: key);

  @override
  State<ReturnedPhotoPage> createState() => _ReturnedPhotoPageState();
}

class _ReturnedPhotoPageState extends HiState<ReturnedPhotoPage> {
  List<File> _images = [];
  bool submitEnable = false;

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
      body: Container(
          child: ListView(children: [
        ListTile(
          title: const Text("Batch Num: "),
          subtitle: Text("${widget.returnedParcel.batch_num}"),
        ),
        ListTile(
          title: const Text("Order Num: "),
          subtitle: Text("${widget.returnedParcel.order_num}"),
        ),
        ListTile(
          title: const Text("Shipment Num: "),
          subtitle: Text("${widget.returnedParcel.shpmt_num}"),
        ),
        ListTile(
          title: const Text("Pictures: "),
          subtitle:
              _images.isEmpty ? const Text("No Pictures") : const Text(""),
        ),
        Center(
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: _genImages(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: LoginButton(
            'Upload',
            enable: submitEnable,
            onPressed: upload,
          ),
        )
      ])),
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

  void upload() async {
    setState(() {
      submitEnable = false; // 防止重复提交
    });
    List attachments = [];
    int index = 1;
    for (var img in _images) {
      final bytes = img.readAsBytesSync();
      // print(bytes.lengthInBytes);
      attachments.add({
        "i": index++,
        "filename": img.path.split("/").last,
        "content": base64.encode(bytes),
      });
    }
    print(attachments);
    try {
      var result = await ReturnedDao.uploadPictures(
          widget.returnedParcel.id, attachments);
      if (result['status'] == "succ") {
        showToast("Upload Pictures Successful");
      } else {
        showWarnToast(result['reason'].join(","));
      }
    } catch (e) {
      print(e);
      showWarnToast(e.toString());
    }
    HiNavigator.getInstance().onJumpTo(RouteStatus.returnedNeedPhoto);
  }
}
