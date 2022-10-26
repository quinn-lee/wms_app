import 'package:flutter/material.dart';
import 'package:wms_app/core/hi_state.dart';
import 'package:wms_app/navigator/hi_navigator.dart';
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
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.scanner),
            title: const Text("Check Orders(Drop Shipping)"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance().onJumpTo(RouteStatus.outboundCheck);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text("Check Orders Multiple(Drop Shipping)"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance()
                  .onJumpTo(RouteStatus.outboundCheckMultiple);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text("Outbound Oos Registration"),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              HiNavigator.getInstance()
                  .onJumpTo(RouteStatus.outboundOosRegistration);
            },
          ),
        ],
      ),
    );
  }
}
