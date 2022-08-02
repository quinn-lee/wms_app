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
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.scanner),
            title: const Text("Receive Parcels"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance().onJumpTo(RouteStatus.inboundReceive);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text("Unknown Parcels"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance().onJumpTo(RouteStatus.unknownPacks,
                  args: {"unknownPageFrom": "menu"});
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("Fba Detach Parcels Scan"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance().onJumpTo(RouteStatus.fbaDetachScan);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("Fba Detach Parcels List"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance().onJumpTo(RouteStatus.fbaDetachCurrent);
            },
          ),
        ],
      ),
    );
  }
}
