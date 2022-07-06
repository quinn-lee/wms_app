import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
import 'package:wms_app/widget/home_appbar.dart';

class InboundPage extends StatefulWidget {
  const InboundPage({Key? key}) : super(key: key);

  @override
  State<InboundPage> createState() => _InboundPageState();
}

class _InboundPageState extends HiState<InboundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: homeAppBar("Inbound"),
        body: Container(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.scanner),
                title: const Text("Receive Parcels"),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  HiNavigator.getInstance()
                      .onJumpTo(RouteStatus.inboundReceive);
                },
              ),
            ],
          ),
        ));
  }
}
