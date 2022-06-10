// 自定义顶部appBar
import 'package:flutter/material.dart';
import 'package:wms_app/db/hi_cache.dart';
import 'package:wms_app/http/dao/login_dao.dart';
import 'package:wms_app/navigator/hi_navigator.dart';

homeAppBar(String title) {
  return AppBar(
    // 让title居左
    centerTitle: false,
    titleSpacing: 18,
    title: Text(
      title,
      style: const TextStyle(fontSize: 18),
    ),
    actions: [
      InkWell(
        onTap: () {
          HiCache.getInstance().remove(LoginDao.TOKEN);
          HiNavigator.getInstance().onJumpTo(RouteStatus.login);
        },
        child: Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            alignment: Alignment.center,
            child: Text(
              "Logout",
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            )),
      )
    ],
  );
}
