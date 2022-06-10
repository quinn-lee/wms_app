import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/widget/home_appbar.dart';

class OutboundPage extends StatefulWidget {
  const OutboundPage({Key? key}) : super(key: key);

  @override
  State<OutboundPage> createState() => _OutboundPageState();
}

class _OutboundPageState extends HiState<OutboundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar("Outbound"),
      body: const Center(
        child: Text('Waiting for development'),
      ),
    );
  }
}
