import 'package:flutter/material.dart';
import 'package:wms_app/model/returned_parcel.dart';

class DetailPage extends StatefulWidget {
  final ReturnedParcel rParcel;

  const DetailPage(this.rParcel, {Key? key}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body:
            Container(child: Text('详情页, parcel: ${widget.rParcel.parcelId}')));
  }
}