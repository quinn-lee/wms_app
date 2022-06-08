// 自定义顶部appBar
import 'package:flutter/material.dart';

homeAppBar(String title) {
  return AppBar(
    // 让title居左
    centerTitle: true,
    titleSpacing: 0,
    title: Text(
      title,
      style: const TextStyle(fontSize: 18),
    ),
  );
}
