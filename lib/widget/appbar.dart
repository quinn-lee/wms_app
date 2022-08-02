// 自定义顶部appBar
import 'package:flutter/material.dart';

appBar(String title, String righttitle, VoidCallback? rightButtonClick,
    {VoidCallback? backPressed}) {
  return AppBar(
    // 让title居左
    centerTitle: false,
    titleSpacing: 0,
    leading: BackButton(
      onPressed: backPressed,
    ),
    title: Text(
      title,
      style: const TextStyle(fontSize: 18),
    ),
    actions: [
      InkWell(
        onTap: rightButtonClick,
        child: Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            alignment: Alignment.center,
            child: Text(
              righttitle,
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            )),
      )
    ],
  );
}
