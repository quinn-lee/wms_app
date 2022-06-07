import 'package:flutter/material.dart';

class InboundPage extends StatefulWidget {
  const InboundPage({Key? key}) : super(key: key);

  @override
  State<InboundPage> createState() => _InboundPageState();
}

class _InboundPageState extends State<InboundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Text('入库'),
      ),
    );
  }
}
