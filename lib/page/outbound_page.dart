import 'package:flutter/material.dart';

class OutboundPage extends StatefulWidget {
  const OutboundPage({Key? key}) : super(key: key);

  @override
  State<OutboundPage> createState() => _OutboundPageState();
}

class _OutboundPageState extends State<OutboundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Text('出库'),
      ),
    );
  }
}
